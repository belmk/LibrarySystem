using Library.Models.Email;
using Microsoft.AspNetCore.Mvc;
using EasyNetQ;
using Library.Models.DTOs.Users;


[ApiController]
[Route("api/test-email")]
public class TestController : ControllerBase
{
    private readonly IBus _bus;

    public TestController(IBus bus)
    {
        _bus = bus;
    }

    [HttpPost("publish")]
    public async Task<IActionResult> PublishUser([FromBody] UserInsertDto user)
    {
        var message = new UserRegisteredMessage
        {
            UserId = 1,
            UserName = "test",
            Email = user.Email,
            ActivateUrl = "testUrl"
        };

        // Publish to RabbitMQ
        await _bus.PubSub.PublishAsync(message);

        return Ok(new { status = "Message published to RabbitMQ" });
    }
}

