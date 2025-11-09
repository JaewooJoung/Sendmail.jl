using Sendmail
using Test

@testset "Sendmail.jl" begin
    @testset "Configuration" begin
        @test_throws SystemError Sendmail.configure("nonexistent.toml")
        
        config_content = """
        [smtp]
        server = "smtp.gmail.com"
        port = 587
        use_ssl = true

        [credentials]
        email = "test@gmail.com"
        password = "test123"
        app_password = "testapppass"

        [sender]
        display_name = "Test User"
        display_email = "test@gmail.com"
        """
        
        config_file = tempname() * ".toml"
        write(config_file, config_content)
        
        config = Sendmail.configure(config_file)
        @test config.smtp_server == "smtp.gmail.com"
        @test config.smtp_port == 587
        @test config.use_ssl == true
        @test config.email == "test@gmail.com"
        @test config.display_name == "Test User"
        
        rm(config_file)
    end
    
    @testset "CA Bundle Detection" begin
        ca_bundle = Sendmail.find_ca_bundle()
        if ca_bundle !== nothing
            @test isfile(ca_bundle) || isdir(ca_bundle)
        end
    end
    
    @testset "Send Email Interface" begin
        config_content = """
        [smtp]
        server = "smtp.gmail.com"
        port = 587
        use_ssl = true

        [credentials]
        email = "test@gmail.com"
        password = "test123"
        app_password = "testapppass"

        [sender]
        display_name = "Test User"
        display_email = "test@gmail.com"
        """
        
        config_file = tempname() * ".toml"
        write(config_file, config_content)
        Sendmail.configure(config_file)
        
        @test_throws Exception Sendmail.send_email(
            "invalid@test.com",
            "Test",
            "<p>Test</p>"
        )
        
        rm(config_file)
    end
end
