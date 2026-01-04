package com.library.model;

public class User {
    private int userId;
    private String name;
    private String username;
    private String email;
    private String password;
    private String role;
    private int roleId;
    private String status;


    public User() {}


    public User(int userId, String name, String username, String email, int roleId, String status) {
        this.userId = userId;
        this.name = name;
        this.username = username;
        this.email = email;
        this.roleId = roleId;
        this.status = status;
    }


    public User(int userId, String name, String username, String email, String password, int roleId, String status) {
        this.userId = userId;
        this.name = name;
        this.username = username;
        this.email = email;
        this.password = password;
        this.roleId = roleId;
        this.status = status;
    }

    // --- GETTERS AND SETTERS ---
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public int getRoleId() { return roleId; }
    public void setRoleId(int roleId) { this.roleId = roleId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}