﻿module syslog.serviceclient;

import vibe.core.core:runTask;
import vibe.core.log:logError;
import vibe.http.client;

///
class SyslogServiceClient
{
private:
	immutable string m_url;
	bool m_logSendErrors = false;

public:

	///
	@property void logSendErrors(bool _val) { m_logSendErrors = _val; }

	///
	this(in string _url)
	{
		import std.string:endsWith;

		if(_url.length > 0 && !_url.endsWith("/"))
			m_url = _url~"/";
		else
			m_url = _url;
	}

	///
	void log(string _event)(in string[string] params)
	{
		if(m_url.length == 0)
			return;

		runTask({
			auto requestUrl = m_url~getAdditionalUrlString()~_event;

			try 
			{
				auto res = requestHTTP(requestUrl,
				(scope HTTPClientRequest req) {
					prepareRequest(req);
		
					import vibe.http.form;
					req.writeFormBody(params);
				});
				scope(exit) res.dropBody();
			}
			catch(Exception e)
			{
				if(m_logSendErrors)
					logError("syslog send error");
			}
		});
	}

	///
	void log(string _event)()
	{
		if(m_url.length == 0)
			return;

		runTask({
			auto requestUrl = m_url~getAdditionalUrlString()~_event;

			try 
			{
				auto res = requestHTTP(requestUrl,
				(scope HTTPClientRequest req) {
					prepareRequest(req);

					req.writeBody(cast(ubyte[])"");
				});
				scope(exit) res.dropBody();
			}
			catch(Exception e)
			{
				if(m_logSendErrors)
					logError("syslog send error");
			}
		});
	}

	///
	protected string getAdditionalUrlString()
	{
		return "";
	}

	///
	private static void prepareRequest(scope HTTPClientRequest req)
	{
		req.method = HTTPMethod.POST;
	}
}

version(none)
{
	shared static this()
	{
		SyslogServiceClient logger = new SyslogServiceClient("http://localhost:8888/");

		logger.log!"event1"();

		logger.log!"event2"(["param2":"value"]);
	}
}
