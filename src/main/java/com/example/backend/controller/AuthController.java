package com.example.backend.controller;
import org.springframework.web.bind.annotation.*;

@RestController
public class AuthController {

    @PostMapping("/login")
    public String login(@RequestBody User user) {
        if ("dhanashri".equals(user.getUsername()) && "dm1234".equals(user.getPassword())) {
            return "Welcome Dhanashri!";
        } else if ("admin".equals(user.getUsername()) && "admin1234".equals(user.getPassword())) {
            return "Welcome Admin!";
        } else {
            return "Invalid credentials";
        }
    }

    static class User {
        private String username;
        private String password;

        // Getters and Setters
        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }
    }
}
