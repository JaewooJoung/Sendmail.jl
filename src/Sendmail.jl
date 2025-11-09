#════════════════════════════════════════════════════════════════════════════════
# 📧 SENDMAIL MODULE
#════════════════════════════════════════════════════════════════════════════════
# 📁 File:      Sendmail.jl
# 📝 Brief:     Simple and reliable email sending via SMTP with SSL/TLS support
# 🔧 Features:  SMTP send, TOML config, SSL/TLS, CC/BCC, Priority levels
# 👤 Author:    Jaewoo Joung 郑在祐 (jaewoo.joung@outlook.com)
# 🏢 Company:   Volvo Group Purchasing
# 📅 Updated:   2025-11-09
# 📜 License:   MIT License & JSD (Just Simple Distribution)

module Sendmail

using LibCURL
using TOML

export send_email, configure

mutable struct Config
    smtp_server::String
    smtp_port::Int
    use_ssl::Bool
    email::String
    password::String
    app_password::String
    display_name::String
    display_email::String
    ca_bundle::Union{String, Nothing}
end

const DEFAULT_CONFIG = Ref{Union{Config, Nothing}}(nothing)

function find_ca_bundle()
    ca_paths = [
        "/etc/ssl/certs/ca-certificates.crt",
        "/etc/pki/tls/certs/ca-bundle.crt",
        "/etc/ssl/ca-bundle.pem",
        "/etc/ssl/cert.pem",
        "/usr/local/share/certs/ca-root-nss.crt",
        "/etc/pki/tls/cert.pem",
        "/etc/ssl/certs/"
    ]
    for path in ca_paths
        if isfile(path) || isdir(path)
            return path
        end
    end
    return nothing
end

function configure(config_file::String="config.toml")
    toml_config = TOML.parsefile(config_file)
    
    DEFAULT_CONFIG[] = Config(
        toml_config["smtp"]["server"],
        toml_config["smtp"]["port"],
        get(toml_config["smtp"], "use_ssl", true),
        toml_config["credentials"]["email"],
        toml_config["credentials"]["password"],
        get(ENV, "EMAIL_APP_PASSWORD", get(toml_config["credentials"], "app_password", "")),
        toml_config["sender"]["display_name"],
        toml_config["sender"]["display_email"],
        find_ca_bundle()
    )
    
    println("✓ Sendmail configured: $(DEFAULT_CONFIG[].email)")
    return DEFAULT_CONFIG[]
end

function curl_read_cb(ptr::Ptr{Cchar}, size::Csize_t, nmemb::Csize_t, userdata::Ptr{Cvoid})::Csize_t
    nbytes = size * nmemb
    io = unsafe_pointer_to_objref(userdata)::IOBuffer
    available = bytesavailable(io)
    if available == 0
        return Csize_t(0)
    end
    to_read = min(Int(nbytes), available)
    data = Vector{UInt8}(undef, to_read)
    read!(io, data)
    dest_ptr = Ptr{UInt8}(ptr)
    unsafe_copyto!(dest_ptr, pointer(data), to_read)
    return Csize_t(to_read)
end

function send_email(recipient, subject, body_text; 
                   priority=3, cc=nothing, bcc=nothing, use_display_name=true)
    
    if DEFAULT_CONFIG[] === nothing
        configure()
    end
    
    config = DEFAULT_CONFIG[]
    
    if !(priority in [1, 3, 5])
        priority = 3
    end
    
    auth_password = !isempty(config.app_password) ? config.app_password : config.password
    priority_label = priority == 1 ? "High" : (priority == 5 ? "Low" : "Normal")
    
    cc_header = ""
    cc_list = String[]
    if cc !== nothing
        cc_list = typeof(cc) <: AbstractString ? [cc] : collect(cc)
        cc_header = "Cc: " * join(cc_list, ", ") * "\r\n"
    end
    
    to_list = typeof(recipient) <: AbstractString ? [recipient] : collect(recipient)
    all_recipients = copy(to_list)
    append!(all_recipients, cc_list)
    if bcc !== nothing
        bcc_list = typeof(bcc) <: AbstractString ? [bcc] : collect(bcc)
        append!(all_recipients, bcc_list)
    end
    
    sender_name = use_display_name ? config.display_name : split(config.email, "@")[1]
    sender_email_display = use_display_name ? config.display_email : config.email
    
    message = "From: $sender_name <$sender_email_display>\r\n" *
              "To: $(join(to_list, ", "))\r\n" *
              cc_header *
              "Subject: $subject\r\n" *
              "X-Priority: $priority\r\n" *
              "X-MSMail-Priority: $priority_label\r\n" *
              "Importance: $priority_label\r\n" *
              "MIME-Version: 1.0\r\n" *
              "Content-Type: text/html; charset=UTF-8\r\n" *
              "\r\n" *
              body_text

    url = "smtp://$(config.smtp_server):$(config.smtp_port)"
    curl = curl_easy_init()
    curl_easy_setopt(curl, CURLOPT_URL, url)
    curl_easy_setopt(curl, CURLOPT_MAIL_FROM, "<$(config.email)>")

    recipients = C_NULL
    for r in all_recipients
        recipients = curl_slist_append(recipients, "<$r>")
    end
    curl_easy_setopt(curl, CURLOPT_MAIL_RCPT, recipients)
    curl_easy_setopt(curl, CURLOPT_USERNAME, config.email)
    curl_easy_setopt(curl, CURLOPT_PASSWORD, auth_password)

    if config.use_ssl
        curl_easy_setopt(curl, CURLOPT_USE_SSL, CURLUSESSL_ALL)
        if config.ca_bundle !== nothing
            if isdir(config.ca_bundle)
                curl_easy_setopt(curl, CURLOPT_CAPATH, config.ca_bundle)
            else
                curl_easy_setopt(curl, CURLOPT_CAINFO, config.ca_bundle)
            end
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1)
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 2)
        else
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0)
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0)
        end
    else
        curl_easy_setopt(curl, CURLOPT_USE_SSL, CURLUSESSL_NONE)
    end

    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 30)
    curl_easy_setopt(curl, CURLOPT_VERBOSE, 0)

    message_io = IOBuffer(message)
    seekstart(message_io)
    c_read_callback = @cfunction(curl_read_cb, Csize_t, (Ptr{Cchar}, Csize_t, Csize_t, Ptr{Cvoid}))
    curl_easy_setopt(curl, CURLOPT_READFUNCTION, c_read_callback)
    curl_easy_setopt(curl, CURLOPT_READDATA, message_io)
    curl_easy_setopt(curl, CURLOPT_UPLOAD, Cint(1))

    res = curl_easy_perform(curl)

    curl_slist_free_all(recipients)
    curl_easy_cleanup(curl)

    if res == CURLE_OK
        return true
    else
        error_msg = unsafe_string(curl_easy_strerror(res))
        @warn "Failed to send email: $error_msg"
        return false
    end
end

end
