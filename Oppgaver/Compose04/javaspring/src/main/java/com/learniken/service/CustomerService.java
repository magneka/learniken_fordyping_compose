package com.learniken.service;

import com.learniken.entity.Customer;
import com.learniken.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CustomerService {

    @Autowired
    private CustomerRepository customerRepository;

    public List<Customer> getAllCustomers() {
        return customerRepository.findAll();
    }

    public Optional<Customer> getCustomerById(Integer id) {
        return customerRepository.findById(id);
    }

    public Customer createCustomer(Customer customer) {
        return customerRepository.save(customer);
    }

    public Customer updateCustomer(Integer id, Customer customerDetails) {
        Optional<Customer> customer = customerRepository.findById(id);
        if (customer.isPresent()) {
            Customer existingCustomer = customer.get();
            if (customerDetails.getFirstName() != null) {
                existingCustomer.setFirstName(customerDetails.getFirstName());
            }
            if (customerDetails.getLastName() != null) {
                existingCustomer.setLastName(customerDetails.getLastName());
            }
            if (customerDetails.getEmail() != null) {
                existingCustomer.setEmail(customerDetails.getEmail());
            }
            if (customerDetails.getPhone() != null) {
                existingCustomer.setPhone(customerDetails.getPhone());
            }
            if (customerDetails.getCity() != null) {
                existingCustomer.setCity(customerDetails.getCity());
            }
            return customerRepository.save(existingCustomer);
        }
        return null;
    }

    public boolean deleteCustomer(Integer id) {
        if (customerRepository.existsById(id)) {
            customerRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
