package com.library.controller;

import com.library.dao.UserDAO;
import com.library.dao.TransactionDAO;
import com.library.model.User;
import com.library.model.Transaction;
import com.library.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;

@WebServlet("/UserProfileServlet")
public class UserProfileServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final TransactionDAO transDAO = new TransactionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser != null) {

            List<Transaction> history = transDAO.getUserHistory(currentUser.getUserId());
            double totalFines = 0;
            for (Transaction t : history) {
                totalFines += t.getFineAmount();
            }


            request.setAttribute("profileInfo", currentUser);
            request.setAttribute("totalFines", totalFines);

            request.getRequestDispatcher("user_dashboard.jsp").forward(request, response);
        } else {
            response.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        String currentPassFromForm = request.getParameter("currentPassword");
        String newPass = request.getParameter("newPassword");

        response.setContentType("text/plain");

        if (currentUser == null) {
            response.getWriter().write("Session expired. Please login again.");
            return;
        }


        String storedPassword = currentUser.getPassword();
        if (storedPassword == null) {
            response.getWriter().write("Error: Current password data missing from session. Please logout and login again.");
            return;
        }


        if (!storedPassword.equals(currentPassFromForm)) {
            response.getWriter().write("Current password is incorrect.");
            return;
        }


        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE users SET password = ? WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newPass);
                ps.setInt(2, currentUser.getUserId());

                if (ps.executeUpdate() > 0) {

                    currentUser.setPassword(newPass);
                    response.getWriter().write("Password updated successfully!");
                } else {
                    response.getWriter().write("Failed to update password.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Server error: " + e.getMessage());
        }
    }
}