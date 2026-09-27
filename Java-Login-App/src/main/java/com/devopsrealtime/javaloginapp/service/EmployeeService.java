package com.devopsrealtime.javaloginapp.service;

import com.devopsrealtime.javaloginapp.model.Employee;
import com.devopsrealtime.javaloginapp.repository.EmployeeRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class EmployeeService {

    private final EmployeeRepository employeeRepository;
    private final PasswordEncoder passwordEncoder;

    public EmployeeService(EmployeeRepository employeeRepository,
                           PasswordEncoder passwordEncoder) {
        this.employeeRepository = employeeRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public boolean register(Employee employee) {

        Employee existingEmployee =
                employeeRepository.findByUsername(employee.getUsername());

        if (existingEmployee != null) {
            return false;
        }

        String encodedPassword =
                passwordEncoder.encode(employee.getPassword());

        employee.setPassword(encodedPassword);

        employeeRepository.save(employee);

        return true;
    }
}
