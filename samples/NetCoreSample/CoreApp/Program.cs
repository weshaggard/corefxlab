using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Security;
using System.Net.Sockets;
using System.Text;


namespace coreApp
{
    public class Program
    {
        static void Main(string[] args)
        {
            Uri address = new Uri("https://www.msn.com:443");
            IPAddress ipv4Address = Dns.GetHostAddressesAsync(address.Host).Result.First(ip => ip.AddressFamily == AddressFamily.InterNetwork);

            using (Socket socket = new Socket(SocketType.Stream, ProtocolType.Tcp))
            {
                socket.Connect(ipv4Address, address.Port);
                using (NetworkStream networkStream = new NetworkStream(socket, false))
                using (SslStream sslStream = new SslStream(networkStream))
                {
                    sslStream.AuthenticateAsClientAsync(address.Host).Wait();
                    StreamWriter requestWriter = new StreamWriter(sslStream, Encoding.ASCII, 4096, true);
                    requestWriter.Write("GET https://" + address.Host + "/ HTTP/1.1\r\n");
                    requestWriter.Write("Host: " + address.Host + "\r\n");
                    requestWriter.Write("\r\n");
                    requestWriter.Write("\r\n");
                    requestWriter.Flush();

                    StreamReader responseReader = new StreamReader(sslStream, Encoding.ASCII, false, 4096, true);
                    string responseLine;
                    while (!string.IsNullOrEmpty((responseLine = responseReader.ReadLine())))
                    {
                        Console.WriteLine(responseLine);
                    }
                }
            }
        }
    }
}
