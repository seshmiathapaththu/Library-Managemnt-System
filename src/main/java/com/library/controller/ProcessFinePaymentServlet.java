package com.library.controller;

import com.library.util.DBConnection;
import com.library.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/ProcessFinePaymentServlet")
public class ProcessFinePaymentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String source = request.getParameter("source");
        boolean isUser = "user".equalsIgnoreCase(source);

        String transIdStr = request.getParameter("transactionId");
        String paidAmountStr = request.getParameter("amount");
        User currentUser = (User) request.getSession().getAttribute("user");

        if (transIdStr == null || paidAmountStr == null || currentUser == null) {
            if (isUser) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("INVALID_REQUEST");
            } else {
                response.sendRedirect("LibrarianDashboardServlet?tab=transactions&error=Missing_Data");
            }
            return;
        }

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int transactionId = Integer.parseInt(transIdStr);
            double paidAmount = Double.parseDouble(paidAmountStr);

            int memberId;
            double currentFine;


            String findSql =
                    "SELECT user_id, fine_amount FROM transactions WHERE transaction_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(findSql)) {
                ps.setInt(1, transactionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) throw new Exception("Transaction not found");
                    memberId = rs.getInt("user_id");
                    currentFine = rs.getDouble("fine_amount");
                }
            }


            String insertSql =
                    "INSERT INTO payments (user_id, transaction_id, amount, payment_method) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, memberId);
                ps.setInt(2, transactionId);
                ps.setDouble(3, paidAmount);
                ps.setString(4, "Card");
                ps.executeUpdate();
            }


            double newBalance = Math.max(0, currentFine - paidAmount);
            String updateSql =
                    "UPDATE transactions SET fine_amount = ?, status = ? WHERE transaction_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setDouble(1, newBalance);
                ps.setString(2, newBalance == 0 ? "Returned" : "Issued");
                ps.setInt(3, transactionId);
                ps.executeUpdate();
            }

            conn.commit();


            if (isUser) {
                response.setContentType("text/plain");
                response.getWriter().write("SUCCESS");
            } else {
                response.sendRedirect(
                        "LibrarianDashboardServlet?tab=transactions&success=Payment_Processed"
                );
            }

        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            e.printStackTrace();

            if (isUser) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("ERROR");
            } else {
                response.sendRedirect(
                        "LibrarianDashboardServlet?tab=transactions&error=Database_Error"
                );
            }

        } finally {
            try { if (conn != null) conn.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }
}
