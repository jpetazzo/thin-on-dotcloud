require 'sinatra'

conns = []

get '/' do
  erb :index
end

get '/subscribe' do
  content_type 'text/event-stream'
  stream(:keep_open) do |out|
    conns << out
    out.callback { conns.delete(out) }
    out << "event: init\n\n"
    out << "data: there are now #{conns.length} stream(s).\n\n"
  end
end

get '/publish' do
  conns.each do |out|
    out << "event: publish\n\n"
    out << "data: hello #{out}!\n\n"
  end
  "published to #{conns.length} stream(s).\n"
end

__END__

@@ index
  <article id="log"></article>

  <script>
    var source = new EventSource('/subscribe');

    source.addEventListener('message', function (event) {
      log.innerText += '\n' + event.data;
    }, false);
  </script>
