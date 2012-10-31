require 'sinatra'
require 'redis'

conns = []

get '/' do
  erb :index
end

get '/subscribe' do
  content_type 'text/event-stream'
  stream(:keep_open) do |out|
    conns << out
    out.callback { conns.delete(out) }
  end
end

get '/publish' do
  conns.each do |out|
    out << "hello #{out}!\n"
  end
  "published to #{conns.length} stream(s)."
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
