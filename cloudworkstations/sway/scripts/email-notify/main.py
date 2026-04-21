"""Cloud Function to send email notifications for Cloud Workstation setup."""

import functions_framework
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


@functions_framework.http
def notify(request):
    """Send an email notification. Accepts JSON: {to, subject, body}."""
    data = request.get_json(silent=True)
    if not data:
        return ("Missing JSON body", 400)

    to_addr = data.get("to")
    subject = data.get("subject", "Cloud Workstation Notification")
    body = data.get("body", "")

    if not to_addr:
        return ("Missing 'to' field", 400)

    msg = MIMEMultipart("alternative")
    msg["Subject"] = subject
    msg["From"] = f"Cloud Workstation <ws-notify@cloudworkstation.dev>"
    msg["To"] = to_addr
    msg.attach(MIMEText(body, "html"))

    # Try multiple SMTP methods
    errors = []

    # Method 1: Google Workspace SMTP relay (works for Workspace orgs)
    try:
        with smtplib.SMTP("smtp-relay.gmail.com", 587, timeout=10) as s:
            s.starttls()
            s.send_message(msg)
        return (f"Email sent to {to_addr} via smtp-relay", 200)
    except Exception as e:
        errors.append(f"smtp-relay: {e}")

    # Method 2: Direct MX delivery to Google (works for Gmail/Workspace recipients)
    try:
        with smtplib.SMTP("aspmx.l.google.com", 25, timeout=10) as s:
            s.send_message(msg)
        return (f"Email sent to {to_addr} via MX", 200)
    except Exception as e:
        errors.append(f"MX: {e}")

    # Method 3: Alt Google MX servers
    for mx in ["alt1.aspmx.l.google.com", "alt2.aspmx.l.google.com"]:
        try:
            with smtplib.SMTP(mx, 25, timeout=10) as s:
                s.send_message(msg)
            return (f"Email sent to {to_addr} via {mx}", 200)
        except Exception as e:
            errors.append(f"{mx}: {e}")

    return (f"All email methods failed: {'; '.join(errors)}", 500)
