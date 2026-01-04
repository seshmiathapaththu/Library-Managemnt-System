package com.library.controller;

import com.library.model.User;
import com.library.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/ReservationServlet")
public class ReservationServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String bookIdStr = request.getParameter("bookId");
        User user = (User) request.getSession().getAttribute("user");


        if (user == null || bookIdStr == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("User session expired or Book ID missing.");
            return;
        }

        int bookId;
        try {
            bookId = Integer.parseInt(bookIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid Book ID format.");
            return;
        }


        try (Connection conn = DBConnection.getConnection()) {


            String checkSql = "SELECT reservation_id FROM reservations WHERE user_id = ? AND book_id = ? AND status = 'Pending'";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, user.getUserId());
                checkPs.setInt(2, bookId);

                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {

                        response.setStatus(HttpServletResponse.SC_CONFLICT); // 409 status code
                        response.getWriter().write("You have already reserved this book.");
                        return;
                    }
                }
            }


            String insertSql = "INSERT INTO reservations (user_id, book_id, status) VALUES (?, ?, 'Pending')";
            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setInt(1, user.getUserId());
                insertPs.setInt(2, bookId);

                int result = insertPs.executeUpdate();
                if (result > 0) {
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("Success");
                }
            }

        } catch (SQLException e) {

            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Database error occurred: " + e.getMessage());
        } catch (Exception e) {

            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("An unexpected error occurred.");
        }
    }
}