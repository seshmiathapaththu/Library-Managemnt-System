package com.library.controller;

import com.library.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/DeleteUserServlet")
public class DeleteUserServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userIdStr = request.getParameter("id");
        if (userIdStr == null || userIdStr.isEmpty()) {
            response.sendRedirect("LibrarianDashboardServlet?tab=users&error=Invalid_User_ID");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction to ensure all-or-nothing deletion

            int userId = Integer.parseInt(userIdStr);


            String checkSql = "SELECT COUNT(*) FROM transactions WHERE user_id = ? AND status = 'Issued'";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setInt(1, userId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        response.sendRedirect("LibrarianDashboardServlet?tab=users&error=User_has_active_loans");
                        return;
                    }
                }
            }


            String deleteResSql = "DELETE FROM reservations WHERE user_id = ?";
            try (PreparedStatement psRes = conn.prepareStatement(deleteResSql)) {
                psRes.setInt(1, userId);
                psRes.executeUpdate();
            }


            String deleteTransSql = "DELETE FROM transactions WHERE user_id = ?";
            try (PreparedStatement psTrans = conn.prepareStatement(deleteTransSql)) {
                psTrans.setInt(1, userId);
                psTrans.executeUpdate();
            }


            String deleteUserSql = "DELETE FROM users WHERE user_id = ?";
            try (PreparedStatement psUser = conn.prepareStatement(deleteUserSql)) {
                psUser.setInt(1, userId);
                int rowsAffected = psUser.executeUpdate();

                if (rowsAffected > 0) {
                    conn.commit(); // Finalize all deletions
                    response.sendRedirect("LibrarianDashboardServlet?tab=users&success=User_and_History_Deleted");
                } else {
                    response.sendRedirect("LibrarianDashboardServlet?tab=users&error=User_Not_Found");
                }
            }

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.sendRedirect("LibrarianDashboardServlet?tab=users&error=Database_Error_During_Deletion");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("LibrarianDashboardServlet?tab=users&error=Server_Error");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}