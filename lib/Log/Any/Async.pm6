use v6.c;
use Log::Any;

class Log::Any::Async {
  my $react-runnig = False;
  my $react-stopping = False;
  my $channel = Channel.new;
  my $kill-channel = Channel.new;

  method log(:$msg!, :$severity!, :$category is copy, :$pipeline is copy) {
    if ! $react-runnig {
      self.start-react;
    }

    say "Send: ",{
      msg => $msg,
      severity => $severity,
      "category" => $category,
      pipeline => $pipeline
    }, !!$channel.closed;

    $channel.send({
      msg => $msg,
      severity => $severity,
      "category" => $category,
      pipeline => $pipeline
    });

    say "After send: ", $channel.closed.Bool
  }

  method stop {
    return if $react-stopping;

    $react-stopping = True;

    $channel.close;
    for $channel.list -> $call {
      say "List: ", $call;
      Log::Any.log(
        :severity($call<severity>),
        :msg($call<msg>),
        :category($call<category>),
        :pipeline($call<pipeline>)
      );
    }

    #$channel.send({
    #  _close => True
    #});
    # $kill-channel.receive;
  }

  method start-react {
    return if $react-runnig;
    END {
      self.stop;
    }

    $react-runnig = True;
    start {
      my $call;
      until $channel.closed {
        $call = $channel.receive;


        say "Receive: ", $call;
        #if (($call<_close> // False) == True) {
        #    $kill-channel.send(True);
        #  last;
        #}

        Log::Any.log(
          :severity($call<severity>),
          :msg($call<msg>),
          :category($call<category>),
          :pipeline($call<pipeline>)
        );
      }

      say "Broke loop";
    }
  }

	method emergency( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'emergency' ), :$category, :$pipeline );
	}

	method alert( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'alert' ), :$category, :$pipeline);
	}

	method critical( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'critical' ), :$category, :$pipeline );
	}

	method error( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'error' ), :$category, :$pipeline );
	}

	method warning( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'warning' ), :$category, :$pipeline );
	}

	method info( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'info' ), :$category, :$pipeline );
	}

	method notice( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'notice' ), :$category, :$pipeline );
	}

	method debug( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'debug' ), :$category, :$pipeline );
	}

	method trace( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'trace' ), :$category, :$pipeline );
  }
}
