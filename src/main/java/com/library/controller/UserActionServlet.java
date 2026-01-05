package com.library.controller;

import com.library.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/UserActionServlet")
public class UserActionServlet extends HttpServlet {
    private UserDAO dao = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        boolean success = false;


        try {
            if ("add".equals(action)) {
                success = dao.addUser(
                        request.getParameter("name"),
                        request.getParameter("username"),
                        request.getParameter("email"),
                        request.getParameter("password"),
                        Integer.parseInt(request.getParameter("roleId"))
                );
            } else if ("toggleStatus".equals(action)) {
                success = dao.toggleUserStatus(
                        Integer.parseInt(request.getParameter("userId")),
                        request.getParameter("currentStatus")
                );
            } else if ("delete".equals(action)) {
                success = dao.deleteUser(Integer.parseInt(request.getParameter("userId")));
            }

            else if ("changePassword".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                String newPassword = request.getParameter("newPassword");


                success = dao.updatePassword(userId, newPassword);
            }

        } catch (Exception e) {

            e.printStackTrace();
            success = false;
        }


        response.sendRedirect("admin_dashboard.jsp?status=" + (success ? "success" : "fail"));
    }
}