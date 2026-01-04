package com.library.controller;

import com.library.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/IssueBookServlet")
public class IssueBookServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uIdStr = request.getParameter("userId");
        String bIdStr = request.getParameter("bookId");


        try {
            if (uIdStr == null || bIdStr == null || uIdStr.trim().isEmpty() || bIdStr.trim().isEmpty()) {
                response.sendRedirect("LibrarianDashboardServlet?tab=transactions&error=Missing_Input");
                return;
            }


            try (Connection conn = DBConnection.getConnection()) {
                if (conn == null) throw new SQLException("Could not establish DB connection");

                conn.setAutoCommit(false); // Transactions ensure data integrity

                int userId = Integer.parseInt(uIdStr.trim());
                int bookId = Integer.parseInt(bIdStr.trim());


                String checkSql = "SELECT available_copies FROM books WHERE book_id = ? AND available_copies > 0";
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setInt(1, bookId);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (!rs.next()) {
                            response.sendRedirect("LibrarianDashboardServlet?tab=transactions&error=No_Copies_Available");
                            return;
                        }
                    }
                }


                String insSql = "INSERT INTO transactions (user_id, book_id, issue_date, due_date, status, fine_amount) " +
                        "VALUES (?, ?, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'Issued', 0.00)";

                try (PreparedStatement psIns = conn.prepareStatement(insSql)) {
                    psIns.setInt(1, userId);
                    psIns.setInt(2, bookId);
                    psIns.executeUpdate();
                }


                String updSql = "UPDATE books SET available_copies = available_copies - 1 WHERE book_id = ?";
                try (PreparedStatement psUpd = conn.prepareStatement(updSql)) {
                    psUpd.setInt(1, bookId);
                    psUpd.executeUpdate();
                }

                conn.commit();
                response.sendRedirect("LibrarianDashboardServlet?tab=transactions&success=Book_Issued");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("LibrarianDashboardServlet?tab=transactions&error=Invalid_ID_Format");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("LibrarianDashboardServlet?tab=transactions&error=Database_Error_" + e.getErrorCode());
        } catch (Exception e) {

            e.printStackTrace();
            response.sendRedirect("LibrarianDashboardServlet?tab=transactions&error=Server_Error");
        }
    }
}