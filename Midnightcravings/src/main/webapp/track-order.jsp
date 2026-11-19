
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List,java.util.Map,java.util.Date,java.text.SimpleDateFormat,java.util.Locale,jakarta.servlet.http.HttpServletResponse" %>

<%!
    public String escapeHtml(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    public String safeValue(Object value) {
        return value == null ? "" : String.valueOf(value);
    }

    public String formatMoney(Object value) {
        try {
            return String.format(Locale.US, "%.2f",
                Double.parseDouble(String.valueOf(value)));
        } catch (Exception e) {
            return "0.00";
        }
    }

    public String normalizeOrderStatus(Object value) {
        return safeValue(value).trim().toLowerCase(Locale.ROOT)
            .replace("_", " ").replace("-", " ");
    }
%>

<%
    String contextPath = request.getContextPath();

    Map<String, Object> order =
        (Map<String, Object>) request.getAttribute("order");

    if (order == null) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
        return;
    }

    String orderId = safeValue(order.get("orderId"));
    String safeOrderId = orderId.matches("\\d+") ? orderId : "0";
    String status = safeValue(order.get("status"));
    String restaurantName = safeValue(order.get("restaurantName"));
    String paymentMethod = safeValue(order.get("paymentMethod"));
    String deliveryAddress = safeValue(order.get("deliveryAddress"));
    String totalAmount = formatMoney(order.get("totalAmount"));

    Object orderDateObj = order.get("orderDate");
    String formattedOrderDate = "Not available";
    SimpleDateFormat displayDate =
        new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);

    if (orderDateObj instanceof Date) {
        formattedOrderDate = displayDate.format((Date) orderDateObj);
    } else if (orderDateObj != null) {
        formattedOrderDate = safeValue(orderDateObj);
    }

    String normalizedStatus = normalizeOrderStatus(status);

    boolean cancelled = normalizedStatus.contains("cancel")
        || normalizedStatus.contains("reject");

    boolean delivered = normalizedStatus.equals("delivered")
        || normalizedStatus.equals("completed");

    boolean outForDelivery = normalizedStatus.contains("out for delivery");

    boolean pickedUp = normalizedStatus.contains("picked up")
        || normalizedStatus.contains("pickedup");

    boolean preparing = normalizedStatus.contains("prepar");

    boolean confirmed = normalizedStatus.contains("confirm")
        || normalizedStatus.contains("accept");

    int currentStep = 0;
    if (confirmed) currentStep = 1;
    if (preparing) currentStep = 2;
    if (pickedUp) currentStep = 3;
    if (outForDelivery) currentStep = 4;
    if (delivered) currentStep = 5;

    List<Map<String, Object>> orderItems =
        (List<Map<String, Object>>) request.getAttribute("orderItems");

    String feedbackResult = safeValue(request.getParameter("feedback"));
    boolean feedbackSuccess = "success".equals(feedbackResult);
    boolean feedbackFailed = "failed".equals(feedbackResult);
    boolean feedbackAlreadySubmitted =
        "alreadySubmitted".equals(feedbackResult);

    boolean hasFeedback =
        Boolean.TRUE.equals(request.getAttribute("hasFeedback"))
        || feedbackSuccess || feedbackAlreadySubmitted;

    String initialHeading;
    String initialDescription;
    String initialIcon;

    if (cancelled) {
        initialHeading = "Order Cancelled";
        initialDescription = "This order has been cancelled or rejected.";
        initialIcon = "fa-xmark";
    } else if (delivered) {
        initialHeading = "Order Delivered!";
        initialDescription = "Your food has arrived. Enjoy your meal!";
        initialIcon = "fa-check";
    } else if (outForDelivery) {
        initialHeading = "Out for Delivery";
        initialDescription = "Your delivery agent is on the way.";
        initialIcon = "fa-motorcycle";
    } else if (pickedUp) {
        initialHeading = "Order Picked Up";
        initialDescription = "Your delivery agent has picked up your order.";
        initialIcon = "fa-box";
    } else if (preparing) {
        initialHeading = "Preparing Your Order";
        initialDescription = "The restaurant is preparing your food.";
        initialIcon = "fa-fire-burner";
    } else if (confirmed) {
        initialHeading = "Order Confirmed";
        initialDescription = "The restaurant has confirmed your order.";
        initialIcon = "fa-circle-check";
    } else {
        initialHeading = status.isEmpty() ? "Order Placed" : status;
        initialDescription = "We will update your order progress here.";
        initialIcon = "fa-clock";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Track Order | Midnight Cravings</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">

    <style>
        :root {
            --cream:#FFFDF7;
            --yellow:#FFC025;
            --yellow-dark:#D69B00;
            --ink:#29251C;
            --muted:#817762;
            --line:#EEE8D9;
            --green:#27864A;
            --red:#C74636;
        }

        * { box-sizing:border-box; }

        body {
            margin:0;
            background:var(--cream);
            color:var(--ink);
            font-family:'Plus Jakarta Sans',sans-serif;
        }

        a { color:inherit; text-decoration:none; }

        .navbar {
            min-height:76px;
            padding:0 7%;
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:15px;
            background:#fff;
            border-bottom:1px solid var(--line);
        }

        .brand { font-size:21px; font-weight:800; letter-spacing:-.8px; }
        .brand span { color:var(--yellow-dark); }

        .back-link {
            display:inline-flex;
            align-items:center;
            gap:9px;
            font-size:13px;
            font-weight:700;
        }

        .page { max-width:1180px; margin:36px auto 60px; padding:0 22px; }
        .page-heading { margin-bottom:25px; }
        .page-heading h1 { margin:0 0 8px; font-size:clamp(25px,4vw,34px); letter-spacing:-1.2px; }
        .page-heading p { margin:0; color:var(--muted); font-size:13px; line-height:1.8; }

        .order-number {
            display:inline-block;
            margin-top:12px;
            background:#FFF3CB;
            color:#765600;
            padding:8px 12px;
            border-radius:8px;
            font-size:12px;
            font-weight:800;
        }

        .layout {
            display:grid;
            grid-template-columns:minmax(0,1.55fr) minmax(280px,.85fr);
            gap:24px;
            align-items:start;
        }

        .left-column,.right-column { display:grid; gap:22px; min-width:0; }

        .card {
            background:#fff;
            border:1px solid var(--line);
            border-radius:18px;
            padding:24px;
            box-shadow:0 6px 25px rgba(55,44,15,.035);
            min-width:0;
        }

        .card-heading {
            display:flex;
            justify-content:space-between;
            align-items:center;
            flex-wrap:wrap;
            gap:12px;
            margin-bottom:20px;
        }

        .card-heading h2 { font-size:16px; margin:0; font-weight:800; }
        .card-heading h2 i { color:var(--yellow-dark); margin-right:8px; }

        .status-banner {
            background:#FFF7DF;
            border:1px solid #F5E5B6;
            border-radius:14px;
            padding:19px;
            display:flex;
            align-items:center;
            gap:14px;
            margin-bottom:24px;
        }

        .status-icon {
            height:48px;
            width:48px;
            min-width:48px;
            border-radius:50%;
            background:var(--yellow);
            display:grid;
            place-items:center;
            font-size:20px;
        }

        .status-banner h3 { margin:0 0 6px; font-size:15px; }
        .status-banner p { margin:0; color:var(--muted); font-size:12px; line-height:1.7; overflow-wrap:anywhere; }

        .cancelled-banner { background:#FFF0EE; border-color:#F4D1CC; }
        .cancelled-banner .status-icon { background:#F8D6D1; color:var(--red); }
        .delivered-banner { background:#EFF9F0; border-color:#D2EAD5; }
        .delivered-banner .status-icon { background:#D6F0DA; color:var(--green); }

        .timeline-scroll { width:100%; overflow-x:auto; padding:8px 2px 15px; }
        .timeline { display:grid; grid-template-columns:repeat(6,minmax(100px,1fr)); min-width:650px; }
        .timeline-step { min-width:0; display:flex; flex-direction:column; }
        .timeline-track { width:100%; height:54px; display:flex; align-items:center; }

        .timeline-dot {
            width:46px;
            height:46px;
            min-width:46px;
            border:2px solid #E8E1D2;
            border-radius:50%;
            background:#fff;
            display:grid;
            place-items:center;
            font-size:17px;
            color:#A69D8B;
            z-index:2;
        }

        .timeline-line { height:4px; flex:1; min-width:12px; background:#E8E1D2; border-radius:10px; margin:0 5px; }
        .timeline-step.completed .timeline-dot { background:var(--yellow); border-color:var(--yellow); color:var(--ink); }
        .timeline-step.completed .timeline-line { background:var(--yellow); }
        .timeline-step.current .timeline-dot { background:var(--ink); border-color:var(--ink); color:#fff; box-shadow:0 0 0 5px #FFF0C1; }

        .timeline-content { padding:12px 8px 0 0; }
        .timeline-content h4 { margin:0 0 7px; font-size:11px; font-weight:800; line-height:1.6; }
        .timeline-content p { margin:0; font-size:10px; color:var(--muted); line-height:1.8; }
        .timeline-step:not(.completed):not(.current) .timeline-content h4 { color:#9D9585; }
        .timeline-step.completed .timeline-content h4 { color:#795800; }

        .info-list { display:grid; gap:18px; }
        .info-row { display:flex; align-items:flex-start; gap:13px; }
        .info-icon { width:36px; height:36px; min-width:36px; display:grid; place-items:center; border-radius:11px; background:#FFF5D9; color:#9C7200; }
        .info-row h4 { margin:1px 0 5px; font-size:12px; }
        .info-row p { margin:0; font-size:12px; line-height:1.8; color:var(--muted); overflow-wrap:anywhere; }

        .item-row {
            display:flex;
            justify-content:space-between;
            align-items:flex-start;
            gap:12px;
            padding:13px 0;
            border-bottom:1px solid #F2EEE5;
        }

        .item-row:first-child { padding-top:0; }
        .item-row:last-child { border-bottom:none; }
        .item-name { font-size:12px; font-weight:700; line-height:1.7; overflow-wrap:anywhere; }
        .item-quantity { font-size:11px; color:var(--muted); margin-top:4px; }
        .item-price { font-size:12px; font-weight:800; white-space:nowrap; }

        .total-row {
            border-top:1px dashed #DDD4C1;
            margin-top:12px;
            padding-top:18px;
            display:flex;
            justify-content:space-between;
            align-items:center;
            gap:10px;
            font-weight:800;
            font-size:14px;
        }

        .total-value { font-size:20px; white-space:nowrap; }
        .payment-pill { display:inline-block; background:#F5F1E7; padding:6px 10px; border-radius:7px; font-size:10px; font-weight:800; margin-top:10px; overflow-wrap:anywhere; }

        .action-button,.download-bill-btn {
            width:100%;
            min-height:46px;
            display:flex;
            justify-content:center;
            align-items:center;
            gap:9px;
            padding:12px 16px;
            border:1px solid var(--yellow);
            border-radius:11px;
            background:var(--yellow);
            color:var(--ink);
            font-family:inherit;
            font-size:12px;
            font-weight:800;
            cursor:pointer;
            text-align:center;
            transition:background .2s;
        }

        .action-button:hover,.download-bill-btn:hover { background:#FFD15B; }
        .secondary-button { background:#fff; border-color:var(--line); margin-top:10px; }
        .secondary-button:hover { background:#FFF8E7; }
        .download-bill-btn { margin-bottom:10px; border-color:var(--yellow-dark); }

        #deliveryMap { width:100%; height:320px; border-radius:13px; background:#F5F2E9; overflow:hidden; z-index:1; }
        .location-message,.location-updated { font-size:12px; line-height:1.8; color:var(--muted); }
        .location-updated { font-size:10px; }

        .live-label { display:inline-flex; align-items:center; gap:6px; background:#EAF7EB; color:#24743A; border-radius:20px; padding:6px 9px; font-size:10px; font-weight:800; }
        .live-dot { width:7px; height:7px; border-radius:50%; background:#28A745; }

        .map-note { margin-top:12px; padding:11px 12px; border-radius:10px; background:#FFF8E6; color:#79642D; font-size:11px; line-height:1.8; }

        .feedback-intro { color:var(--muted); font-size:12px; line-height:1.8; margin:-6px 0 18px; }
        .feedback-label { display:block; font-size:12px; font-weight:800; margin:16px 0 9px; }

        .rating-options { display:flex; flex-direction:row-reverse; justify-content:flex-end; gap:8px; margin:8px 0 14px; }
        .rating-options input { position:absolute; opacity:0; width:1px; height:1px; }
        .rating-options label { cursor:pointer; color:#D9D2C3; font-size:30px; transition:color .15s; }
        .rating-options label:hover,.rating-options label:hover ~ label,.rating-options input:checked ~ label { color:#FFC025; }
        .rating-options input:focus-visible + label { outline:2px solid var(--ink); outline-offset:3px; }

        .feedback-textarea {
            display:block;
            width:100%;
            min-height:105px;
            resize:vertical;
            padding:13px;
            border:1px solid var(--line);
            border-radius:11px;
            background:#FFFDF9;
            color:var(--ink);
            font:inherit;
            font-size:12px;
            line-height:1.7;
        }

        .feedback-textarea:focus { outline:2px solid #FFE08A; border-color:var(--yellow-dark); }

        .feedback-message { padding:13px 14px; border-radius:10px; font-size:12px; line-height:1.8; margin-bottom:15px; }
        .feedback-message.success { background:#EFF9F0; border:1px solid #D2EAD5; color:#24743A; }
        .feedback-message.error { background:#FFF0EE; border:1px solid #F4D1CC; color:#A12F25; }
        .feedback-message.info { background:#FFF7DF; border:1px solid #F5E5B6; color:#765600; }

        .footer-note { text-align:center; color:var(--muted); font-size:11px; line-height:1.8; margin-top:30px; }

        @media(max-width:800px) {
            .layout { grid-template-columns:1fr; }
            .page { margin-top:25px; padding:0 14px; }
            .navbar { padding:0 18px; }
            .card { padding:19px; }
            #deliveryMap { height:280px; }
        }

        @media(max-width:420px) {
            .brand { font-size:17px; }
            .back-link { font-size:11px; }
            .card-heading h2 { font-size:14px; }
            .timeline { min-width:620px; }
        }
    </style>
</head>

<body>
<nav class="navbar">
    <a class="brand" href="<%= contextPath %>/home">Midnight <span>Cravings</span></a>
    <a class="back-link" href="<%= contextPath %>/home">
        <i class="fa-solid fa-arrow-left"></i> Back to Home
    </a>
</nav>

<main class="page">
    <div class="page-heading">
        <h1>Track your order <i class="fa-solid fa-location-dot" style="color:#D69B00"></i></h1>
        <p>Follow your order's progress from the restaurant to your doorstep.</p>
        <span class="order-number">Order #<%= escapeHtml(orderId) %></span>
    </div>

    <div class="layout">
        <div class="left-column">

            <% if (!cancelled && !delivered) { %>
            <section class="card" id="liveTrackingCard" style="display:none">
                <div class="card-heading">
                    <h2><i class="fa-solid fa-map-location-dot"></i> Live Delivery Location</h2>
                    <span class="live-label"><span class="live-dot"></span> LIVE TRACKING</span>
                </div>
                <div id="deliveryMap"></div>
                <p class="location-message" id="locationMessage">Waiting for the delivery agent's GPS location...</p>
                <p class="location-updated" id="locationUpdated"></p>
                <div class="map-note"><i class="fa-solid fa-circle-info"></i> If GPS sharing is paused, the map keeps the last location received.</div>
            </section>

            <section class="card" id="waitingTrackingCard">
                <div class="card-heading"><h2><i class="fa-solid fa-clock"></i> Live Tracking</h2></div>
                <div class="status-banner" style="margin-bottom:0">
                    <div class="status-icon"><i class="fa-solid fa-utensils"></i></div>
                    <div>
                        <h3 id="waitingTrackingHeading">Waiting for pickup</h3>
                        <p id="waitingTrackingMessage">Live tracking will appear after the delivery agent picks up your order and shares a GPS location.</p>
                    </div>
                </div>
            </section>
            <% } %>

            <section class="card">
                <div class="card-heading"><h2><i class="fa-solid fa-box-open"></i> Order Status</h2></div>

                <div class="status-banner <%= cancelled ? "cancelled-banner" : (delivered ? "delivered-banner" : "") %>">
                    <div class="status-icon"><i class="fa-solid <%= initialIcon %>"></i></div>
                    <div>
                        <h3 id="orderStatusHeading"><%= escapeHtml(initialHeading) %></h3>
                        <p id="orderStatusDescription"><%= escapeHtml(initialDescription) %></p>
                    </div>
                </div>

                <% if (!cancelled) {
                    String[] stepTitles = {"Order Placed","Confirmed","Preparing","Picked Up","On the Way","Delivered"};
                    String[] stepDescriptions = {"We've received your order.","The restaurant confirmed it.","Your food is being prepared.","The agent collected your food.","Your order is on its way.","Enjoy your meal!"};
                    String[] stepIcons = {"fa-receipt","fa-circle-check","fa-fire-burner","fa-box","fa-motorcycle","fa-house-circle-check"};
                %>
                <div class="timeline-scroll" id="timelineScroll">
                    <div class="timeline" id="orderTimeline">
                        <% for (int i = 0; i < stepTitles.length; i++) {
                            boolean stepCompleted = delivered || i < currentStep;
                            boolean stepCurrent = !delivered && i == currentStep;
                        %>
                        <div class="timeline-step <%= stepCompleted ? "completed" : "" %> <%= stepCurrent ? "current" : "" %>">
                            <div class="timeline-track">
                                <div class="timeline-dot">
                                    <% if (stepCompleted) { %>
                                        <i class="fa-solid fa-check"></i>
                                    <% } else { %>
                                        <i class="fa-solid <%= stepIcons[i] %>"></i>
                                    <% } %>
                                </div>
                                <% if (i < stepTitles.length - 1) { %><div class="timeline-line"></div><% } %>
                            </div>
                            <div class="timeline-content">
                                <h4><%= stepTitles[i] %></h4>
                                <p><%= stepDescriptions[i] %></p>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </section>

            <% if (delivered) { %>
            <section class="card" id="feedbackCard">
                <div class="card-heading"><h2><i class="fa-solid fa-star"></i> Rate Your Experience</h2></div>

                <% if (feedbackSuccess) { %>
                    <div class="feedback-message success" role="status">
                        <i class="fa-solid fa-circle-check"></i> Thank you! Your feedback has been submitted successfully.
                    </div>
                <% } else if (feedbackAlreadySubmitted || hasFeedback) { %>
                    <div class="feedback-message info" role="status">
                        <i class="fa-solid fa-circle-check"></i> You have already submitted feedback for this order. Thank you!
                    </div>
                <% } else if (feedbackFailed) { %>
                    <div class="feedback-message error" role="alert">
                        <i class="fa-solid fa-circle-exclamation"></i> We couldn't save your feedback. Please try again.
                    </div>
                <% } %>

                <% if (!hasFeedback) { %>
                <p class="feedback-intro">Your order has been delivered! Tell us how we did. Your rating helps us improve Midnight Cravings.</p>

                <form action="<%= contextPath %>/feedback" method="post" id="feedbackForm">
                    <input type="hidden" name="orderId" value="<%= escapeHtml(safeOrderId) %>">

                    <label class="feedback-label">How would you rate your experience?</label>
                    <div class="rating-options" aria-label="Choose a star rating">
                        <% for (int rating = 5; rating >= 1; rating--) { %>
                            <input type="radio" id="rating<%= rating %>" name="rating" value="<%= rating %>" required>
                            <label for="rating<%= rating %>" title="<%= rating %> stars">&#9733;</label>
                        <% } %>
                    </div>

                    <label class="feedback-label" for="feedbackComment">Share your comments (optional)</label>
                    <textarea class="feedback-textarea" id="feedbackComment" name="comment" maxlength="500" placeholder="Tell us about the food and delivery experience..."></textarea>
                    <p style="font-size:10px;color:#817762;line-height:1.7">Maximum 500 characters.</p>

                    <button class="action-button" type="submit" id="submitFeedbackButton">
                        <i class="fa-solid fa-paper-plane"></i> Submit Feedback
                    </button>
                </form>
                <% } %>
            </section>
            <% } %>

            <section class="card">
                <div class="card-heading"><h2><i class="fa-solid fa-receipt"></i> Delivery Details</h2></div>
                <div class="info-list">
                    <div class="info-row">
                        <div class="info-icon"><i class="fa-solid fa-store"></i></div>
                        <div><h4>Restaurant</h4><p><%= escapeHtml(restaurantName) %></p></div>
                    </div>
                    <div class="info-row">
                        <div class="info-icon"><i class="fa-solid fa-location-dot"></i></div>
                        <div><h4>Delivery Address</h4><p><%= escapeHtml(deliveryAddress) %></p></div>
                    </div>
                    <div class="info-row">
                        <div class="info-icon"><i class="fa-regular fa-calendar"></i></div>
                        <div><h4>Order Date</h4><p><%= escapeHtml(formattedOrderDate) %></p></div>
                    </div>
                    <div class="info-row">
                        <div class="info-icon"><i class="fa-solid fa-credit-card"></i></div>
                        <div><h4>Payment Method</h4><p><%= escapeHtml(paymentMethod) %></p></div>
                    </div>
                </div>
            </section>
        </div>

        <aside class="right-column">
            <section class="card">
                <div class="card-heading"><h2><i class="fa-solid fa-bag-shopping"></i> Order Summary</h2></div>

                <% if (orderItems != null && !orderItems.isEmpty()) {
                    for (Map<String, Object> item : orderItems) {
                        if (item == null) continue;
                %>
                    <div class="item-row">
                        <div>
                            <div class="item-name"><%= escapeHtml(item.get("itemName")) %></div>
                            <div class="item-quantity">Qty: <%= escapeHtml(item.get("quantity")) %></div>
                        </div>
                        <div class="item-price">₹<%= formatMoney(item.get("itemTotal")) %></div>
                    </div>
                <% } } else { %>
                    <p style="color:#817762;font-size:12px;line-height:1.8">Order item details are not available.</p>
                <% } %>

                <div class="total-row">
                    <span>Total Amount</span>
                    <span class="total-value">₹<%= totalAmount %></span>
                </div>
                <span class="payment-pill"><i class="fa-solid fa-credit-card"></i> <%= escapeHtml(paymentMethod) %></span>
            </section>

            <section class="card">
                <div class="card-heading"><h2><i class="fa-solid fa-headset"></i> Need Help?</h2></div>
                <p style="font-size:12px;color:#817762;line-height:1.9;margin:0 0 18px">
                    Check your order progress here. Live GPS tracking is available after the delivery agent picks up your food and sends a location.
                </p>

                <a class="download-bill-btn" href="<%= contextPath %>/download-bill?orderId=<%= safeOrderId %>">
                    <i class="fa-solid fa-file-pdf"></i> Download Bill (PDF)
                </a>
                <a class="action-button secondary-button" href="<%= contextPath %>/home">
                    <i class="fa-solid fa-utensils"></i> Order More Food
                </a>
                <button class="action-button secondary-button" type="button" id="refreshOrderButton">
                    <i class="fa-solid fa-rotate-right"></i> Refresh Order
                </button>
            </section>
        </aside>
    </div>

    <div class="footer-note">Made with <i class="fa-solid fa-heart" style="color:#D69B00"></i> by Midnight Cravings</div>
</main>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<script>
(function () {
    "use strict";

    const orderId = <%= safeOrderId %>;
    const contextPath = "<%= contextPath %>";
    const initiallyCancelled = <%= cancelled %>;
    const initiallyDelivered = <%= delivered %>;

    const trackingCard = document.getElementById("liveTrackingCard");
    const waitingCard = document.getElementById("waitingTrackingCard");
    const waitingHeading = document.getElementById("waitingTrackingHeading");
    const waitingMessage = document.getElementById("waitingTrackingMessage");
    const messageElement = document.getElementById("locationMessage");
    const updatedElement = document.getElementById("locationUpdated");
    const refreshButton = document.getElementById("refreshOrderButton");

    let map = null;
    let agentMarker = null;
    let hasReceivedLocation = false;
    let requestInProgress = false;
    let trackingStopped = false;
    let pollingTimer = null;

    const stepIconClasses = [
        "fa-receipt","fa-circle-check","fa-fire-burner",
        "fa-box","fa-motorcycle","fa-house-circle-check"
    ];

    function normalize(value) {
        return String(value || "").trim().toLowerCase()
            .replace(/[_-]+/g, " ").replace(/\s+/g, " ");
    }

    function getCurrentStep(value) {
        value = normalize(value);
        if (value === "delivered" || value === "completed") return 5;
        if (value.includes("out for delivery")) return 4;
        if (value.includes("picked up") || value.includes("pickedup")) return 3;
        if (value.includes("prepar")) return 2;
        if (value.includes("confirm") || value.includes("accept")) return 1;
        return 0;
    }

    function updateTimeline(value) {
        const timeline = document.getElementById("orderTimeline");
        if (!timeline) return;

        const current = getCurrentStep(value);

        timeline.querySelectorAll(".timeline-step").forEach(function (step, index) {
            step.classList.remove("completed", "current");
            if (index < current) step.classList.add("completed");
            else if (index === current) step.classList.add("current");

            const dot = step.querySelector(".timeline-dot");
            if (dot) {
                const icon = document.createElement("i");
                icon.className = "fa-solid " +
                    (index < current ? "fa-check" : stepIconClasses[index]);
                dot.replaceChildren(icon);
            }
        });
    }

    function updateStatusDisplay(latestStatus, deliveryStatus) {
        const heading = document.getElementById("orderStatusHeading");
        const description = document.getElementById("orderStatusDescription");
        const banner = heading ? heading.closest(".status-banner") : null;

        const orderStatus = normalize(latestStatus);
        const assignment = normalize(deliveryStatus);

        let title = latestStatus || "Order Placed";
        let detail = "We will update your order progress here.";
        let timelineStatus = latestStatus || "Order Placed";
        let iconClass = "fa-clock";

        if (assignment === "assigned") {
            title = "Waiting for Delivery Agent";
            detail = "Your order is waiting for the assigned delivery agent to accept it.";
        } else if (assignment === "accepted") {
            title = "Delivery Agent Accepted";
            detail = "Your delivery agent has accepted the order and is preparing to collect it.";
            timelineStatus = orderStatus.includes("prepar") ? "Preparing" : "Confirmed";
            iconClass = "fa-circle-check";
        } else if (assignment === "picked up") {
            title = "Order Picked Up";
            detail = "Your delivery agent has picked up your order.";
            timelineStatus = "Picked Up";
            iconClass = "fa-box";
        } else if (assignment === "out for delivery") {
            title = "Out for Delivery";
            detail = "Your delivery agent is on the way to your address.";
            timelineStatus = "Out for Delivery";
            iconClass = "fa-motorcycle";
        } else if (orderStatus.includes("prepar")) {
            detail = "The restaurant is preparing your food.";
            timelineStatus = "Preparing";
            iconClass = "fa-fire-burner";
        } else if (orderStatus.includes("confirm") || orderStatus.includes("accept")) {
            detail = "The restaurant has confirmed your order.";
            timelineStatus = "Confirmed";
            iconClass = "fa-circle-check";
        }

        if (heading) heading.textContent = title;
        if (description) description.textContent = detail;

        if (banner) {
            const icon = banner.querySelector(".status-icon i");
            if (icon) icon.className = "fa-solid " + iconClass;
        }

        updateTimeline(timelineStatus);
    }

    function stopTracking() {
        trackingStopped = true;
        if (pollingTimer !== null) {
            window.clearInterval(pollingTimer);
            pollingTimer = null;
        }
    }

    function updateCompletedStatus(isCancelled) {
        const heading = document.getElementById("orderStatusHeading");
        const description = document.getElementById("orderStatusDescription");
        const banner = heading ? heading.closest(".status-banner") : null;
        const timeline = document.getElementById("orderTimeline");
        const timelineScroll = document.getElementById("timelineScroll");

        if (heading) heading.textContent = isCancelled ? "Order Cancelled" : "Order Delivered!";
        if (description) {
            description.textContent = isCancelled
                ? "This order has been cancelled or rejected."
                : "Your food has arrived. Enjoy your meal!";
        }

        if (banner) {
            banner.classList.remove("cancelled-banner", "delivered-banner");
            banner.classList.add(isCancelled ? "cancelled-banner" : "delivered-banner");
            const icon = banner.querySelector(".status-icon i");
            if (icon) icon.className = isCancelled ? "fa-solid fa-xmark" : "fa-solid fa-check";
        }

        if (timeline) {
            if (isCancelled) {
                timeline.style.display = "none";
            } else {
                timeline.querySelectorAll(".timeline-step").forEach(function (step) {
                    step.classList.remove("current");
                    step.classList.add("completed");
                    const dot = step.querySelector(".timeline-dot");
                    if (dot) {
                        const icon = document.createElement("i");
                        icon.className = "fa-solid fa-check";
                        dot.replaceChildren(icon);
                    }
                });
            }
        }

        if (timelineScroll && isCancelled) timelineScroll.style.display = "none";
        if (trackingCard) trackingCard.remove();
        if (waitingCard) waitingCard.remove();
        stopTracking();
    }

    function showWaiting(message) {
        if (trackingCard) trackingCard.style.display = "none";
        if (waitingCard) waitingCard.style.display = "block";
        if (waitingHeading) waitingHeading.textContent = "Waiting for pickup";
        if (waitingMessage && message) waitingMessage.textContent = message;
    }

    function initializeMap(latitude, longitude) {
        if (!trackingCard || typeof L === "undefined") {
            if (waitingMessage) {
                waitingMessage.textContent = "The map could not load. Check your internet connection.";
            }
            return false;
        }

        trackingCard.style.display = "block";
        if (waitingCard) waitingCard.style.display = "none";

        if (!map) {
            map = L.map("deliveryMap").setView([latitude, longitude], 16);
            L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
                maxZoom: 19,
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            }).addTo(map);
        }

        window.setTimeout(function () {
            if (map) map.invalidateSize();
        }, 100);

        return true;
    }

    async function updateDeliveryLocation() {
        if (requestInProgress || trackingStopped) return;
        requestInProgress = true;

        try {
            const response = await fetch(
                contextPath + "/get-delivery-location?orderId=" +
                encodeURIComponent(orderId) + "&_=" + Date.now(),
                {
                    method: "GET",
                    credentials: "same-origin",
                    cache: "no-store",
                    headers: {"Accept":"application/json"}
                }
            );

            const raw = await response.text();
            let data;

            try {
                data = JSON.parse(raw);
            } catch (error) {
                throw new Error("The tracking server returned an invalid response.");
            }

            if (!response.ok) {
                throw new Error(data.message || "Unable to retrieve order tracking.");
            }

            const latestStatus = String(data.orderStatus || data.status || "").trim();
            const normalizedOrderStatus = normalize(latestStatus);
            const deliveryStatus = String(data.deliveryStatus || "").trim();
            const normalizedDeliveryStatus = normalize(deliveryStatus);

            const isDelivered = data.delivered === true ||
                normalizedOrderStatus === "delivered" ||
                normalizedOrderStatus === "completed" ||
                normalizedDeliveryStatus === "delivered";

            const isCancelled = data.cancelled === true ||
                normalizedOrderStatus.includes("cancel") ||
                normalizedOrderStatus.includes("reject") ||
                normalizedDeliveryStatus === "rejected" ||
                normalizedDeliveryStatus === "cancelled" ||
                normalizedDeliveryStatus === "canceled";

            if (isDelivered || isCancelled) {
                updateCompletedStatus(isCancelled);
                return;
            }

            updateStatusDisplay(latestStatus, deliveryStatus);

            const agentHasPickedUp =
                normalizedDeliveryStatus === "picked up" ||
                normalizedDeliveryStatus === "out for delivery";

            const hasCoordinates =
                data.latitude !== null && data.latitude !== undefined &&
                String(data.latitude).trim() !== "" &&
                data.longitude !== null && data.longitude !== undefined &&
                String(data.longitude).trim() !== "";

            if (!agentHasPickedUp || !hasCoordinates) {
                let message;

                if (normalizedDeliveryStatus === "assigned") {
                    message = "Your order is waiting for the delivery agent to accept it. Live tracking will appear after pickup and the first GPS update.";
                } else if (normalizedDeliveryStatus === "accepted") {
                    message = "The delivery agent accepted your order. Live tracking will appear after pickup and the first GPS update.";
                } else if (agentHasPickedUp) {
                    message = "The delivery agent has picked up your order. Waiting for the first GPS location.";
                } else {
                    message = "Your order is waiting for pickup. Live tracking will appear after the delivery agent picks it up and shares a GPS location.";
                }

                showWaiting(message);
                return;
            }

            const latitude = Number(data.latitude);
            const longitude = Number(data.longitude);

            if (!Number.isFinite(latitude) || !Number.isFinite(longitude) ||
                latitude < -90 || latitude > 90 ||
                longitude < -180 || longitude > 180) {
                throw new Error("The server returned invalid GPS coordinates.");
            }

            if (!initializeMap(latitude, longitude)) return;

            const position = [latitude, longitude];

            if (!agentMarker) {
                agentMarker = L.marker(position).addTo(map).bindPopup("Delivery Agent");
                map.setView(position, 16);
            } else {
                agentMarker.setLatLng(position);
            }

            hasReceivedLocation = true;

            if (messageElement) {
                messageElement.textContent = "Showing the delivery agent's latest saved location.";
            }

            if (updatedElement) {
                updatedElement.textContent = data.updatedAt
                    ? "Last location update: " + data.updatedAt
                    : "GPS location received.";
            }

        } catch (error) {
            console.error("Delivery tracking error:", error);

            if (messageElement && trackingCard && trackingCard.style.display !== "none") {
                messageElement.textContent = hasReceivedLocation
                    ? "Unable to refresh GPS. Showing the last known location."
                    : "Unable to retrieve GPS right now. Retrying shortly.";
            } else if (waitingMessage) {
                waitingMessage.textContent = "Unable to refresh order tracking right now. Retrying shortly.";
            }
        } finally {
            requestInProgress = false;
        }
    }

    if (refreshButton) {
        refreshButton.addEventListener("click", function () {
            if (initiallyCancelled || initiallyDelivered) {
                window.location.reload();
            } else {
                updateDeliveryLocation();
            }
        });
    }

    if (!initiallyCancelled && !initiallyDelivered && orderId > 0) {
        showWaiting("Live tracking will appear after the delivery agent picks up your order and shares a GPS location.");
        updateDeliveryLocation();

        pollingTimer = window.setInterval(updateDeliveryLocation, 5000);
        window.addEventListener("pagehide", stopTracking);
    }

    const feedbackForm = document.getElementById("feedbackForm");

    if (feedbackForm) {
        feedbackForm.addEventListener("submit", function (event) {
            const selectedRating =
                feedbackForm.querySelector('input[name="rating"]:checked');

            if (!selectedRating) {
                event.preventDefault();
                alert("Please select a star rating before submitting.");
                return;
            }

            const button = document.getElementById("submitFeedbackButton");
            if (button) {
                button.disabled = true;
                button.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Submitting...';
            }
        });
    }
})();
</script>

</body>
</html>
