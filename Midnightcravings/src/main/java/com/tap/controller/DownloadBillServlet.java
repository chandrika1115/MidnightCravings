
package com.tap.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;

@WebServlet("/download-bill")
public class DownloadBillServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static class BillItem {
        String name;
        int quantity;
        BigDecimal total;

        BillItem(String name, int quantity, BigDecimal total) {
            this.name = name;
            this.quantity = quantity;
            this.total = total;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
                !(session.getAttribute("userId") instanceof Integer)) {
            response.sendRedirect(
                    request.getContextPath() + "/Login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        int orderId;

        try {
            orderId = Integer.parseInt(
                    request.getParameter("orderId"));

            if (orderId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid order ID.");
            return;
        }

        String orderSql =
                "SELECT o.orderId, o.orderDate, o.totalAmount, " +
                "o.status, o.paymentMethod, o.deliveryAddress, " +
                "r.name AS restaurantName " +
                "FROM orders o " +
                "JOIN restaurant r ON o.restaurantId = r.restaurantId " +
                "WHERE o.orderId = ? AND o.userId = ?";

        String itemsSql =
                "SELECT m.itemName, oi.quantity, oi.itemTotal " +
                "FROM orderItem oi " +
                "JOIN menu m ON oi.menuId = m.menuId " +
                "WHERE oi.orderId = ?";

        String restaurantName;
        Timestamp orderDate;
        BigDecimal totalAmount;
        String status;
        String paymentMethod;
        String deliveryAddress;
        List<BillItem> items = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // Only allow the logged-in customer to download their own bill.
            try (PreparedStatement ps = con.prepareStatement(orderSql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendError(
                                HttpServletResponse.SC_NOT_FOUND,
                                "Order not found.");
                        return;
                    }

                    restaurantName = rs.getString("restaurantName");
                    orderDate = rs.getTimestamp("orderDate");
                    totalAmount = rs.getBigDecimal("totalAmount");
                    status = rs.getString("status");
                    paymentMethod = rs.getString("paymentMethod");
                    deliveryAddress = rs.getString("deliveryAddress");
                }
            }

            try (PreparedStatement ps = con.prepareStatement(itemsSql)) {
                ps.setInt(1, orderId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        items.add(new BillItem(
                                rs.getString("itemName"),
                                rs.getInt("quantity"),
                                rs.getBigDecimal("itemTotal")));
                    }
                }
            }

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to retrieve invoice details.", e);
        }

        // Build the PDF in memory.
        try (PDDocument document = new PDDocument()) {

            PDPage page = new PDPage(PDRectangle.A4);
            document.addPage(page);

            try (PDPageContentStream content =
                         new PDPageContentStream(document, page)) {

                float y = 790;
                float left = 50;
                float right = 545;

                writeText(content, PDType1Font.HELVETICA_BOLD,
                        23, left, y, "MIDNIGHT CRAVINGS");
                y -= 25;

                writeText(content, PDType1Font.HELVETICA,
                        11, left, y, "ORDER INVOICE");
                y -= 28;

                content.moveTo(left, y);
                content.lineTo(right, y);
                content.stroke();
                y -= 25;

                writeText(content, PDType1Font.HELVETICA_BOLD,
                        12, left, y, "Order Details");
                y -= 20;

                y = writeWrapped(content, left, y,
                        "Order ID: " + orderId);
                y = writeWrapped(content, left, y,
                        "Order Date: " + formatDate(orderDate));
                y = writeWrapped(content, left, y,
                        "Restaurant: " + restaurantName);
                y = writeWrapped(content, left, y,
                        "Order Status: " + status);
                y = writeWrapped(content, left, y,
                        "Payment Method: " + paymentMethod);
                y = writeWrapped(content, left, y,
                        "Delivery Address: " + deliveryAddress);

                y -= 10;
                writeText(content, PDType1Font.HELVETICA_BOLD,
                        12, left, y, "Items Ordered");
                y -= 22;

                writeText(content, PDType1Font.HELVETICA_BOLD,
                        10, left, y, "Item");
                writeText(content, PDType1Font.HELVETICA_BOLD,
                        10, 365, y, "Qty");
                writeText(content, PDType1Font.HELVETICA_BOLD,
                        10, 420, y, "Item Total (INR)");
                y -= 10;

                content.moveTo(left, y);
                content.lineTo(right, y);
                content.stroke();
                y -= 18;

                for (BillItem item : items) {
                    if (y < 100) {
                        // This simple invoice layout is designed for
                        // typical orders containing a small number of items.
                        break;
                    }

                    writeText(content, PDType1Font.HELVETICA,
                            10, left, y, item.name);
                    writeText(content, PDType1Font.HELVETICA,
                            10, 365, y, String.valueOf(item.quantity));
                    writeText(content, PDType1Font.HELVETICA,
                            10, 420, y,
                            money(item.total));
                    y -= 20;
                }

                y -= 8;
                content.moveTo(left, y);
                content.lineTo(right, y);
                content.stroke();
                y -= 25;

                writeText(content, PDType1Font.HELVETICA_BOLD,
                        14, left, y, "Grand Total");
                writeText(content, PDType1Font.HELVETICA_BOLD,
                        14, 420, y, "INR " + money(totalAmount));
                y -= 35;

                writeText(content, PDType1Font.HELVETICA,
                        10, left, y,
                        "Thank you for ordering with Midnight Cravings!");
            }

            response.setContentType("application/pdf");
            response.setHeader(
                    "Content-Disposition",
                    "attachment; filename=\"Midnight_Cravings_Invoice_Order_"
                            + orderId + ".pdf\"");
            response.setHeader("Cache-Control", "no-store");

            document.save(response.getOutputStream());
            response.flushBuffer();
        }
    }

    private static void writeText(
            PDPageContentStream content,
            PDType1Font font,
            float size,
            float x,
            float y,
            String text) throws IOException {

        content.beginText();
        content.setFont(font, size);
        content.newLineAtOffset(x, y);
        content.showText(pdfSafe(text));
        content.endText();
    }

    private static float writeWrapped(
            PDPageContentStream content,
            float x,
            float y,
            String text) throws IOException {

        String safe = pdfSafe(text);
        int maxLength = 85;

        for (int i = 0; i < safe.length(); i += maxLength) {
            int end = Math.min(i + maxLength, safe.length());

            writeText(content, PDType1Font.HELVETICA,
                    10, x, y, safe.substring(i, end));
            y -= 15;
        }

        return y;
    }

    private static String pdfSafe(String value) {
        if (value == null) {
            return "-";
        }

        // Helvetica uses WinAnsi encoding; replace unsupported characters.
        return value.replace('\n', ' ')
                    .replace('\r', ' ')
                    .replace('\t', ' ')
                    .replaceAll("[^\\u0020-\\u007E\\u00A0-\\u00FF]", "?");
    }

    private static String formatDate(Date date) {
        if (date == null) {
            return "-";
        }

        return new SimpleDateFormat(
                "dd MMM yyyy, hh:mm a", Locale.ENGLISH).format(date);
    }

    private static String money(BigDecimal amount) {
        if (amount == null) {
            return "0.00";
        }

        return String.format(Locale.US, "%.2f", amount);
    }
}
