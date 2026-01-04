package com.library.controller;

import com.library.model.User;
import com.library.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/MyReservationsServlet")
public class MyReservationsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<Map<String, String>> reservations = new ArrayList<>();
        String sql = "SELECT r.reservation_date, b.title, r.status FROM reservations r " +
                "JOIN books b ON r.book_id = b.book_id WHERE r.user_id = ? " +
                "ORDER BY r.reservation_date DESC";


        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, user.getUserId());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> row = new HashMap<>();
                    row.put("title", rs.getString("title"));
                    row.put("date", rs.getTimestamp("reservation_date").toString());
                    row.put("status", rs.getString("status"));
                    reservations.add(row);
                }
            }
        } catch (Exception e) {

            e.printStackTrace();
        }

        request.setAttribute("reservationList", reservations);

        request.getRequestDispatcher("user_dashboard.jsp").forward(request, response);
    }
}