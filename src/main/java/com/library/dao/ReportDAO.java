package com.library.dao;

import java.sql.*;
import java.util.*;

public class ReportDAO {

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/librarydb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
            return DriverManager.getConnection(url, "root", "grace");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver not found.", e);
        }
    }

    public List<Map<String, Object>> getOverdueBooks() {
        String sql = "SELECT t.transaction_id, b.title, u.username AS person, t.due_date AS date, " +
                "DATEDIFF(CURDATE(), t.due_date) AS status " +
                "FROM transactions t " +
                "JOIN books b ON t.book_id = b.book_id " +
                "JOIN users u ON t.user_id = u.user_id " +
                "WHERE t.return_date IS NULL AND t.due_date < CURDATE()";
        return executeQuery(sql);
    }

    public List<Map<String, Object>> getIssueHistory() {
        String sql = "SELECT t.transaction_id, b.title, u.username AS person, t.issue_date AS date, t.status " +
                "FROM transactions t " +
                "JOIN books b ON t.book_id = b.book_id " +
                "JOIN users u ON t.user_id = u.user_id " +
                "ORDER BY t.issue_date DESC";
        return executeQuery(sql);
    }

    public List<Map<String, Object>> getLoginLogs() {
        String sql = "SELECT id, username AS title, ip_address AS person, login_time AS date, status " +
                "FROM login_logs ORDER BY login_time DESC LIMIT 100";
        return executeQuery(sql);
    }


    public List<Map<String, Object>> getPaymentHistory() {
        String sql = "SELECT p.payment_id, " +
                "CONCAT('Trans #', p.transaction_id, ' (Issued: ', t.issue_date, ')') AS title, " +
                "u.username AS person, p.payment_date AS date, " +
                "CONCAT('LKR ', p.amount, ' (', p.payment_method, ')') AS status " +
                "FROM payments p " +
                "JOIN users u ON p.user_id = u.user_id " +
                "JOIN transactions t ON p.transaction_id = t.transaction_id " +
                "ORDER BY p.payment_date DESC";
        return executeQuery(sql);
    }

    private List<Map<String, Object>> executeQuery(String sql) {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = getConnection();
             Statement s = conn.createStatement();
             ResultSet rs = s.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getObject(1));
                row.put("title", rs.getObject(2) != null ? rs.getObject(2) : "N/A");
                row.put("person", rs.getObject(3) != null ? rs.getObject(3) : "N/A");
                row.put("date", rs.getObject(4) != null ? rs.getObject(4).toString() : "N/A");

                Object statusObj = rs.getObject(5);
                String statusStr = (statusObj != null) ? statusObj.toString() : "Unknown";
                if (statusStr.matches("\\d+")) {
                    row.put("status", statusStr + " Days Late");
                } else {
                    row.put("status", statusStr);
                }
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}