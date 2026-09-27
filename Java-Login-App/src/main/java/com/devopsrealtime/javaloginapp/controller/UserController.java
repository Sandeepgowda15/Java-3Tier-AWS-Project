package com.devopsrealtime.javaloginapp.controller;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class UserController {

    @GetMapping("/user")
    public String user(Authentication authentication, Model model) {

        model.addAttribute(
                "username",
                authentication.getName()
        );

        return "user";
    }
}
