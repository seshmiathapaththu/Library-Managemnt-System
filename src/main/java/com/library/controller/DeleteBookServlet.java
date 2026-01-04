package com.library.controller;

import com.library.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/DeleteBookServlet")
public class DeleteBookServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String bookIdStr = request.getParameter("id");


        try {
            if (bookIdStr == null || bookIdStr.trim().isEmpty()) {
                response.sendRedirect("LibrarianDashboardServlet?tab=books&error=Invalid_ID");
                return;
            }

            try (Connection conn = DBConnection.getConnection()) {
                if (conn == null) throw new SQLException("DB Connection is null");


                String checkSql = "SELECT COUNT(*) FROM transactions WHERE book_id = ? AND status = 'Issued'";
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setInt(1, Integer.parseInt(bookIdStr));
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            response.sendRedirect("LibrarianDashboardServlet?tab=books&error=Book_is_currently_issued");
                            return;
                        }
                    }
                }


                String updateSql = "UPDATE books SET status = 'Inactive', available_copies = 0 WHERE book_id = ?";
                try (PreparedStatement psUpd = conn.prepareStatement(updateSql)) {
                    psUpd.setInt(1, Integer.parseInt(bookIdStr));
                    int rows = psUpd.executeUpdate();

                    if (rows > 0) {
                        response.sendRedirect("LibrarianDashboardServlet?tab=books&success=Book_Archived_Successfully");
                    } else {
                        response.sendRedirect("LibrarianDashboardServlet?tab=books&error=Book_Not_Found");
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();

            response.sendRedirect("LibrarianDashboardServlet?tab=books&error=DB_Error_" + e.getMessage().replace(" ", "_"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("LibrarianDashboardServlet?tab=books&error=Server_Internal_Error");
        }
    }
}