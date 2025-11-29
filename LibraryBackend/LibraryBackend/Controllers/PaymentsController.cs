using Library.Models.DTOs.PayPal;
using Library.Models.DTOs.Subscriptions;
using Library.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Globalization;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

[ApiController]
[Route("[controller]")]
public class PaymentsController : ControllerBase
{
    private readonly IConfiguration _config;
    private readonly ISubscriptionService _subscriptionService;
    private readonly HttpClient _http;

    public PaymentsController(IConfiguration config, ISubscriptionService subscriptionService)
    {
        _config = config;
        _http = new HttpClient();
        _subscriptionService = subscriptionService;
    }

    private async Task<string> GetAccessToken()
    {
        var clientId = _config["PayPal:ClientId"];
        var secret = _config["PayPal:Secret"];

        var authToken = Encoding.ASCII.GetBytes($"{clientId}:{secret}");
        var tokenRequestUrl = $"{_config["PayPal:BaseUrl"]}/v1/oauth2/token";

        var request = new HttpRequestMessage(HttpMethod.Post, tokenRequestUrl);
        request.Headers.Authorization =
            new AuthenticationHeaderValue("Basic", Convert.ToBase64String(authToken));
        request.Content = new StringContent("grant_type=client_credentials",
            Encoding.UTF8, "application/x-www-form-urlencoded");

        Console.WriteLine($"Request URI: {tokenRequestUrl}");

        var response = await _http.SendAsync(request);
        var responseJson = await response.Content.ReadAsStringAsync();

        Console.WriteLine("PAYPAL TOKEN RESPONSE:");
        Console.WriteLine(responseJson);

        var token = JsonSerializer.Deserialize<PayPalAccessToken>(
            responseJson,
            new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
        );
        return token?.Access_Token?.Trim();
    }

    [HttpPost("create-paypal-order")]
    public async Task<IActionResult> CreateOrder([FromBody] PayPalCreateOrderRequest body)
    {
        Console.WriteLine("Incoming create order request:");
        Console.WriteLine(JsonSerializer.Serialize(body));

        int userId = body.UserId;
        decimal price = body.Price;
        int days = body.Days;

        string accessToken = await GetAccessToken();
        Console.WriteLine("Using PayPal access token: " + accessToken);

        var paypalOrder = new
        {
            intent = "CAPTURE",
            purchase_units = new[]
            {
            new
            {
                amount = new
                {
                    currency_code = "EUR",
                    value = price.ToString("F2", CultureInfo.InvariantCulture)
                }
            }
        },
            application_context = new
            {
                return_url = $"http://10.0.2.2:7268/payments/success?userId={userId}&days={days}&price={price.ToString(CultureInfo.InvariantCulture)}",
                cancel_url = "http://10.0.2.2:7268/payments/cancel"
            }
        };

        var json = JsonSerializer.Serialize(paypalOrder);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        Console.WriteLine("Sending to PayPal:");
        Console.WriteLine(json);

        var orderUrl = $"{_config["PayPal:BaseUrl"]}/v2/checkout/orders";
        var request = new HttpRequestMessage(HttpMethod.Post, orderUrl);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken.Trim());
        request.Content = content;

        Console.WriteLine("Request URI: " + orderUrl);
        Console.WriteLine("Authorization header: " + request.Headers.Authorization);

        var response = await _http.SendAsync(request);
        var responseJson = await response.Content.ReadAsStringAsync();

        Console.WriteLine("PAYPAL ORDER RESPONSE:");
        Console.WriteLine("Status Code: " + response.StatusCode);
        Console.WriteLine(responseJson);

        if (!response.IsSuccessStatusCode)
            return StatusCode((int)response.StatusCode, responseJson);

        // 4. PARSE PAYPAL RESPONSE
        var orderResponse = JsonSerializer.Deserialize<PayPalCreateOrderResponse>(
            responseJson,
            new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            }
        );

        string approvalUrl = orderResponse.Links
            .First(x => x.Rel == "approve").Href;

        return Ok(new
        {
            orderId = orderResponse.Id,
            approvalUrl = approvalUrl
        });
    }




    [HttpGet("success")]
    public IActionResult PaymentSuccess(int userId, int days, decimal price)
    {
        Console.WriteLine($"PAYMENT SUCCESS → userId={userId}, days={days}, price={price}");

        // TODO: Save subscription into database
        // startDate = DateTime.Now
        // endDate = DateTime.Now.AddDays(days)

        return Content("Payment successful! You may close this window.");
    }

    [HttpPost("capture-paypal-order/{orderId}")]
    public async Task<IActionResult> CaptureOrder(string orderId)
    {
        try
        {
            string accessToken = await GetAccessToken();
            var captureUrl = $"{_config["PayPal:BaseUrl"]}/v2/checkout/orders/{orderId}/capture";


            var request = new HttpRequestMessage(HttpMethod.Post, captureUrl);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            // Send empty JSON object {} as the documentation shows
            request.Content = new StringContent("{}", Encoding.UTF8, "application/json");

            Console.WriteLine($"Capturing order: {orderId}");
            Console.WriteLine($"Capture URL: {captureUrl}");

            var response = await _http.SendAsync(request);
            var responseJson = await response.Content.ReadAsStringAsync();

            Console.WriteLine("PAYPAL CAPTURE RESPONSE:");
            Console.WriteLine($"Status Code: {(int)response.StatusCode} {response.StatusCode}");
            Console.WriteLine($"Response: {responseJson}");

            if (!response.IsSuccessStatusCode)
            {
                Console.WriteLine($"CAPTURE FAILED: {responseJson}");
                return StatusCode((int)response.StatusCode, new
                {
                    error = "Capture failed",
                    paypalResponse = responseJson
                });
            }

            // Parse the response
            var captureResponse = JsonSerializer.Deserialize<PayPalCaptureResponse>(
                responseJson,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
            );

            if (captureResponse?.Status == "COMPLETED")
            {
                Console.WriteLine("CAPTURE COMPLETED SUCCESSFULLY");
                var subscriptionData = new SubscriptionInsertDto
                {
                    StartDate = DateTime.Now,
                    EndDate = DateTime.Now.AddDays(5),
                };
            }

            return Ok(captureResponse);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"EXCEPTION in capture: {ex.Message}");
            return StatusCode(500, new { error = ex.Message });
        }
    }

    [HttpGet("check-paypal-order/{orderId}")]
    public async Task<IActionResult> CheckOrder(string orderId)
    {
        string accessToken = await GetAccessToken();

        var url = $"{_config["PayPal:BaseUrl"]}/v2/checkout/orders/{orderId}";

        var request = new HttpRequestMessage(HttpMethod.Get, url);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

        var response = await _http.SendAsync(request);
        var json = await response.Content.ReadAsStringAsync();

        if (!response.IsSuccessStatusCode)
            return StatusCode((int)response.StatusCode, json);

        return Ok(JsonSerializer.Deserialize<object>(json));
    }


    [HttpGet("cancel")]
    public IActionResult PaymentCancel()
    {
        Console.WriteLine("PAYMENT CANCELLED");
        return Content("Payment cancelled.");
    }
}
