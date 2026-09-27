package com.devopsrealtime.javaloginapp.controller;

import com.devopsrealtime.javaloginapp.model.Employee;
import com.devopsrealtime.javaloginapp.service.EmployeeService;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class RegisterController {

    private final EmployeeService employeeService;

    public RegisterController(EmployeeService employeeService) {
        this.employeeService = employeeService;
    }

    @GetMapping("/register")
    public String showRegisterPage(Model model) {
        model.addAttribute("employee", new Employee());
        return "register";
    }

    @PostMapping("/register")
    public String register(
            @Valid @ModelAttribute("employee") Employee employee,
            BindingResult bindingResult,
            Model model) {

        if (bindingResult.hasErrors()) {
            return "register";
        }

        boolean registered = employeeService.register(employee);

        if (!registered) {
            model.addAttribute(
                    "message",
                    "Username already exists. Please choose another username."
            );
            return "register";
        }

        model.addAttribute(
                "message",
                "User account has been created successfully for "
                        + employee.getUsername()
        );

        return "register";
    }
}




