package com.library.controller;

import com.library.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ReturnBookServlet")
public class ReturnBookServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String transIdStr = request.getParameter("transactionId");
        if (transIdStr == null || transIdStr.isEmpty()) return;


        double fineRatePerDay = 50.0;

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); // Enable transactional update


            String sqlTrans = "UPDATE transactions SET " +
                    "status = 'Returned', " +
                    "return_date = CURDATE(), " +
                    "fine_amount = GREATEST(0, DATEDIFF(CURDATE(), due_date)) * ? " +
                    "WHERE transaction_id = ?";


            String sqlBook = "UPDATE books SET available_copies = available_copies + 1 WHERE book_id = " +
                    "(SELECT book_id FROM transactions WHERE transaction_id = ?)";

            try (PreparedStatement ps1 = conn.prepareStatement(sqlTrans);
                 PreparedStatement ps2 = conn.prepareStatement(sqlBook)) {

                int transId = Integer.parseInt(transIdStr);


                ps1.setDouble(1, fineRatePerDay);
                ps1.setInt(2, transId);


                ps2.setInt(1, transId);

                ps1.executeUpdate();
                ps2.executeUpdate();

                conn.commit();
                response.setStatus(200);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
        }
    }
}