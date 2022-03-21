using System;
using System.Reflection;
using System.Text;
using common;
using Microsoft.AspNetCore.Mvc;

namespace data.Controllers;

[ApiController]
[Route("[controller]")]
public class SystemController : ControllerBase
{
    private readonly ILogger<SystemController> _logger;

    public SystemController(ILogger<SystemController> logger)
    {
        _logger = logger;
    }

    /// <summary>
        /// Basic System Call
        /// </summary>
        /// <returns></returns>
        
        public SystemModel Get()
        {
            _logger.LogDebug("Entering Get");
                      
              
            return new SystemModel
            {
                Name = "Data API",
                Version = Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyFileVersionAttribute>().Version 
      
            };
        }
}
