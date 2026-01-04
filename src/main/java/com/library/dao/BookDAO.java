package com.library.dao;

import com.library.model.Book;
import com.library.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookDAO {

    public boolean addBook(Book book) {
        String sql = "INSERT INTO Books (title, author, isbn, category, total_copies, available_copies, status) VALUES (?, ?, ?, ?, ?, ?, 'Available')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, book.getTitle());
            ps.setString(2, book.getAuthor());
            ps.setString(3, book.getIsbn());
            ps.setString(4, book.getCategory());
            ps.setInt(5, book.getTotalCopies());
            ps.setInt(6, book.getTotalCopies());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {

            e.printStackTrace();
            return false;
        }
    }


    public List<Book> getAllBooks() {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT * FROM Books";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                books.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return books;
    }


    public List<Book> searchBooks(String query, String category, String availability) {
        List<Book> books = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Books WHERE (title LIKE ? OR author LIKE ? OR isbn LIKE ?)");


        if (category != null && !category.isEmpty() && !category.equals("All")) {
            sql.append(" AND category = ?");
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            String q = "%" + query + "%";
            ps.setString(1, q);
            ps.setString(2, q);
            ps.setString(3, q);

            if (category != null && !category.isEmpty() && !category.equals("All")) {
                ps.setString(4, category);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    books.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return books;
    }


    public boolean deleteBook(int bookId) {
        String sql = "DELETE FROM Books WHERE book_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }


    private Book mapRow(ResultSet rs) throws SQLException {
        Book b = new Book();
        b.setBookId(rs.getInt("book_id"));
        b.setTitle(rs.getString("title"));
        b.setAuthor(rs.getString("author"));
        b.setIsbn(rs.getString("isbn"));
        b.setCategory(rs.getString("category"));
        b.setTotalCopies(rs.getInt("total_copies"));
        b.setAvailableCopies(rs.getInt("available_copies"));
        b.setStatus(rs.getString("status"));
        return b;
    }
}