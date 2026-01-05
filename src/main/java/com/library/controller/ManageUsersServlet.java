package com.library.controller;

import com.library.dao.UserDAO;
import com.library.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/ManageUsersServlet")
public class ManageUsersServlet extends HttpServlet {
    private UserDAO dao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> userList = dao.getAllUsers();
        request.setAttribute("userList", userList);
        request.getRequestDispatcher("members_fragment.jsp").forward(request, response);
    }
}