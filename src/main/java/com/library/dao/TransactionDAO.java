package com.library.dao;

import com.library.model.Transaction;
import com.library.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class TransactionDAO {

    public List<Transaction> getUserHistory(int userId) {
        List<Transaction> history = new ArrayList<>();
        String sql = "SELECT t.*, b.title FROM transactions t " +
                "JOIN books b ON t.book_id = b.book_id " +
                "WHERE t.user_id = ? ORDER BY t.issue_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    history.add(mapResultSetToTransaction(rs, false));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return history;
    }

    public List<Transaction> getAllTransactions() {
        List<Transaction> list = new ArrayList<>();
        String sql = "SELECT t.*, u.username, b.title FROM transactions t " +
                "JOIN users u ON t.user_id = u.user_id " +
                "JOIN books b ON t.book_id = b.book_id " +
                "ORDER BY t.issue_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToTransaction(rs, true));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }


    private Transaction mapResultSetToTransaction(ResultSet rs, boolean includeUsername) throws SQLException {
        Transaction t = new Transaction();
        t.setTransactionId(rs.getInt("transaction_id"));
        t.setBookId(rs.getInt("book_id"));
        t.setUserId(rs.getInt("user_id"));
        t.setBookTitle(rs.getString("title"));

        if (includeUsername) {
            t.setUsername(rs.getString("username"));
        }


        Date issueDate = rs.getDate("issue_date");
        Date dueDate = rs.getDate("due_date");
        Date returnDate = rs.getDate("return_date");

        t.setIssueDate(issueDate);
        t.setDueDate(dueDate);
        t.setReturnDate(returnDate);
        t.setStatus(rs.getString("status"));


        double fineAmount = rs.getDouble("fine_amount");


        if ("Issued".equalsIgnoreCase(t.getStatus()) && dueDate != null) {
            LocalDate due = dueDate.toLocalDate();
            LocalDate today = LocalDate.now();

            if (today.isAfter(due)) {
                long daysOverdue = ChronoUnit.DAYS.between(due, today);
                fineAmount = daysOverdue * 100.0; // Daily Rate: 100 LKR
            }
        }

        t.setFineAmount(fineAmount);
        return t;
    }
}