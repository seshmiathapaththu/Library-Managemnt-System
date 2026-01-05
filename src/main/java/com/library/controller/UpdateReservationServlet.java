package com.library.controller; // Matches your folder path

import com.library.dao.ReservationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/UpdateReservationServlet")
public class UpdateReservationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String idParam = request.getParameter("id");
            String status = request.getParameter("status");

            if (idParam != null && status != null) {
                int resId = Integer.parseInt(idParam);
                ReservationDAO resDAO = new ReservationDAO();

                boolean success = resDAO.updateReservationStatus(resId, status);

                if (success) {
                    response.sendRedirect("LibrarianDashboardServlet?tab=reservations&success=Action_Successful");
                } else {
                    response.sendRedirect("LibrarianDashboardServlet?tab=reservations&error=Update_Failed");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("LibrarianDashboardServlet?tab=reservations&error=Server_Error");
        }
    }
}