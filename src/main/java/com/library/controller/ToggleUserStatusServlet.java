package com.library.controller;

import com.library.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/ToggleUserStatusServlet")
public class ToggleUserStatusServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {


        String userIdStr = request.getParameter("id");
        String currentStatus = request.getParameter("current");

        if (userIdStr == null || currentStatus == null) {
            response.sendRedirect("LibrarianDashboardServlet?tab=users&error=InvalidRequest");
            return;
        }


        String newStatus = "Active".equalsIgnoreCase(currentStatus) ? "Deactivated" : "Active";

        try (Connection conn = DBConnection.getConnection()) {

            String sql = "UPDATE users SET status = ? WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, Integer.parseInt(userIdStr));

                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {

                    response.sendRedirect("LibrarianDashboardServlet?tab=users&success=StatusUpdated");
                } else {
                    response.sendRedirect("LibrarianDashboardServlet?tab=users&error=UserNotFound");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("LibrarianDashboardServlet?tab=users&error=DatabaseError");
        }
    }
}