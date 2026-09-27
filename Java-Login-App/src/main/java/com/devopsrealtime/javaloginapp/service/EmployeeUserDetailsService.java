package com.devopsrealtime.javaloginapp.service;

import com.devopsrealtime.javaloginapp.model.Employee;
import com.devopsrealtime.javaloginapp.repository.EmployeeRepository;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class EmployeeUserDetailsService implements UserDetailsService {

    private final EmployeeRepository employeeRepository;

    public EmployeeUserDetailsService(EmployeeRepository employeeRepository) {
        this.employeeRepository = employeeRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username)
            throws UsernameNotFoundException {

        Employee employee =
                employeeRepository.findByUsername(username);

        if (employee == null) {
            throw new UsernameNotFoundException(
                    "User not found: " + username
            );
        }

        return User.withUsername(employee.getUsername())
                .password(employee.getPassword())
                .roles("USER")
                .build();
    }
}
