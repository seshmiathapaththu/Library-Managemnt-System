package com.library.controller;

import com.library.model.User;
import com.library.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/AdminActionServlet")
public class AdminActionServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        int targetUserId = Integer.parseInt(request.getParameter("userId"));
        User admin = (User) request.getSession().getAttribute("user");

        if ("toggleStatus".equals(action)) {
            String newStatus = request.getParameter("status");
            if(updateUserStatus(targetUserId, newStatus)) {
                logActivity(admin.getUserId(), "Updated User " + targetUserId + " to " + newStatus);
            }
        }
        response.sendRedirect("admin_dashboard.jsp");
    }

    private boolean updateUserStatus(int id, String status) {
        String sql = "UPDATE Users SET status = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    private void logActivity(int adminId, String detail) {
        String sql = "INSERT INTO AuditLogs (user_id, action) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, adminId);
            ps.setString(2, detail);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }
}