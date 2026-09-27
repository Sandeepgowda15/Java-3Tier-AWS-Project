package com.devopsrealtime.javaloginapp.repository;

import com.devopsrealtime.javaloginapp.model.Employee;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class EmployeeRepository {

    private final JdbcTemplate jdbcTemplate;

    public EmployeeRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void save(Employee employee) {

        String sql = """
                INSERT INTO employee
                (first_name, last_name, email, username, password, regdate)
                VALUES (?, ?, ?, ?, ?, CURDATE())
                """;

        jdbcTemplate.update(
                sql,
                employee.getFirstName(),
                employee.getLastName(),
                employee.getEmail(),
                employee.getUsername(),
                employee.getPassword()
        );
    }

    public Employee findByUsername(String username) {

        String sql = """
                SELECT id, first_name, last_name, email,
                       username, password, regdate
                FROM employee
                WHERE username = ?
                """;

        List<Employee> employees = jdbcTemplate.query(
                sql,
                (rs, rowNum) -> {

                    Employee employee = new Employee();

                    employee.setId(rs.getInt("id"));
                    employee.setFirstName(rs.getString("first_name"));
                    employee.setLastName(rs.getString("last_name"));
                    employee.setEmail(rs.getString("email"));
                    employee.setUsername(rs.getString("username"));
                    employee.setPassword(rs.getString("password"));
                    employee.setRegdate(rs.getString("regdate"));

                    return employee;
                },
                username
        );

        return employees.isEmpty() ? null : employees.get(0);
    }
}
