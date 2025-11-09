using Sendmail

println("""
╔════════════════════════════════════════════════════════════════╗
║                   Sendmail.jl Examples                         ║
╚════════════════════════════════════════════════════════════════╝
""")

Sendmail.configure("config.toml")

println("\n1️⃣  Basic Email")
println("="^68)
success = Sendmail.send_email(
    "recipient@example.com",
    "Basic Test",
    "<h1>Hello!</h1><p>This is a basic email.</p>"
)
println(success ? "✅ Sent" : "❌ Failed")

println("\n2️⃣  Email with CC and BCC")
println("="^68)
success = Sendmail.send_email(
    "recipient@example.com",
    "CC/BCC Test",
    "<p>Testing CC and BCC functionality</p>",
    cc="cc@example.com",
    bcc="bcc@example.com"
)
println(success ? "✅ Sent" : "❌ Failed")

println("\n3️⃣  High Priority Email")
println("="^68)
success = Sendmail.send_email(
    "recipient@example.com",
    "⚠️ Urgent Message",
    "<h2>This is urgent!</h2><p>Please respond ASAP.</p>",
    priority=1
)
println(success ? "✅ Sent" : "❌ Failed")

println("\n4️⃣  Multiple Recipients")
println("="^68)
success = Sendmail.send_email(
    ["user1@example.com", "user2@example.com", "user3@example.com"],
    "Team Update",
    "<h3>Team Update</h3><p>Message for the whole team.</p>"
)
println(success ? "✅ Sent" : "❌ Failed")

println("\n5️⃣  Complex Email")
println("="^68)
success = Sendmail.send_email(
    ["primary@example.com"],
    "Weekly Report",
    """
    <html>
        <body>
            <h1>Weekly Report</h1>
            <h2>Summary</h2>
            <ul>
                <li>Tasks completed: 15</li>
                <li>In progress: 5</li>
                <li>Blocked: 2</li>
            </ul>
            <h2>Next Steps</h2>
            <p>Review and plan for next sprint.</p>
        </body>
    </html>
    """,
    cc=["manager@example.com", "team@example.com"],
    priority=3
)
println(success ? "✅ Sent" : "❌ Failed")

println("\n" * "="^68)
println("Examples completed!")
