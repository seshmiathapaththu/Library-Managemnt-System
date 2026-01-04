package com.library.dao;

import com.library.model.Reservation;
import com.library.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {


    public List<Reservation> getAllReservations() {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.*, u.username, b.title FROM reservations r " +
                "JOIN users u ON r.user_id = u.user_id " +
                "JOIN books b ON r.book_id = b.book_id " +
                "ORDER BY r.reservation_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Reservation r = new Reservation();
                r.setReservationId(rs.getInt("reservation_id"));
                r.setUserId(rs.getInt("user_id"));
                r.setBookId(rs.getInt("book_id"));
                r.setUsername(rs.getString("username"));
                r.setBookTitle(rs.getString("title"));
                r.setReservationDate(rs.getTimestamp("reservation_date"));
                r.setStatus(rs.getString("status"));
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }


    public boolean updateReservationStatus(int resId, String status) {
        String sql = "UPDATE reservations SET status = ? WHERE reservation_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, resId);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;

        } catch (Exception e) {

            e.printStackTrace();
            return false;
        }
    }
}