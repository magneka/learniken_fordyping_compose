using System.Data;
using CustomerApi;
using Dapper;
using MySqlConnector;

var builder = WebApplication.CreateBuilder(args);

var connectionString = BuildConnectionString(builder.Configuration);
builder.Services.AddTransient<IDbConnection>(_ => new MySqlConnection(connectionString));

var app = builder.Build();

app.MapGet("/health", () => Results.Ok("healthy"));

app.MapGet("/hellyeah", () => Results.Ok("hello Learniken!"));

app.MapGet("/customers", async (IDbConnection db) =>
{
    var customers = await db.QueryAsync<Customer>(
        "SELECT id AS Id, first_name AS FirstName, last_name AS LastName, email AS Email, phone AS Phone, city AS City FROM customer");
    return Results.Ok(customers);
});

app.MapGet("/customers/{id:int}", async (int id, IDbConnection db) =>
{
    var customer = await db.QuerySingleOrDefaultAsync<Customer>(
        "SELECT id AS Id, first_name AS FirstName, last_name AS LastName, email AS Email, phone AS Phone, city AS City FROM customer WHERE id = @id",
        new { id });
    return customer is null ? Results.NotFound() : Results.Ok(customer);
});

app.MapPost("/customers", async (Customer customer, IDbConnection db) =>
{
    const string sql = """
        INSERT INTO customer (first_name, last_name, email, phone, city)
        VALUES (@FirstName, @LastName, @Email, @Phone, @City);
        SELECT LAST_INSERT_ID();
        """;
    var id = await db.ExecuteScalarAsync<int>(sql, customer);
    return Results.Created($"/customers/{id}", customer with { Id = id });
});

app.MapPut("/customers/{id:int}", async (int id, Customer customer, IDbConnection db) =>
{
    const string sql = """
        UPDATE customer
        SET first_name = @FirstName, last_name = @LastName, email = @Email, phone = @Phone, city = @City
        WHERE id = @Id
        """;
    var rows = await db.ExecuteAsync(sql, customer with { Id = id });
    return rows == 0 ? Results.NotFound() : Results.NoContent();
});

app.MapDelete("/customers/{id:int}", async (int id, IDbConnection db) =>
{
    var rows = await db.ExecuteAsync("DELETE FROM customer WHERE id = @id", new { id });
    return rows == 0 ? Results.NotFound() : Results.NoContent();
});

app.Run();

static string BuildConnectionString(IConfiguration config)
{
    var host = config["DB_HOST"] ?? "localhost";
    var port = config["DB_PORT"] ?? "3306";
    var database = config["DB_NAME"] ?? "";
    var user = config["DB_USER"] ?? "";
    var password = config["DB_PASSWORD"] ?? "";
    return $"Server={host};Port={port};Database={database};User={user};Password={password};";
}
