require 'rantly'
module Rantly::Silly
  class << self
    def love_letter(n)
      Rantly.new.extend(Rantly::Silly::Love).value { letter(n) }
    end
  end
end

module Rantly::Silly::Love

  def letter(n=3)
    body = array(n){paragraph}.join "\n\n"
    <<-EOS
#{address}:

#{body}

#{sign}

#{post_script}
EOS
  end
  
  def address
    "my #{extremifier} #{pedestal_label}"
  end

  def extremifier
    choose "most","ultimate","unbelievable","incredible","burning"
  end

  def pedestal_label
    choose "beloved","desire","dove","virgin goddess","existential solution","lighthouse","beacon","holy mother","queen","mistress"
  end

  def double_plus_good
    choose "holy","shiny","glittering","joyous","delicious"
  end

  def how_i_feel
    choose "my heart aches","my spine pines","my spirit wanders and wonders","my soul is awed","my loin burns"
  end

  def paragraph
    array(range(2,4)){ sentence}.join " "
  end

  def sentence
    freq \
    Proc.new { "when #{how_i_feel}, my #{pedestal_label}, i feel the need to #{stalk_action}, but this is not because #{how_i_feel}, but rather a symptom of my being your #{whoami}." },
    Proc.new { "because you are my #{pedestal_label}, and i am your #{whoami}, no, rather your #{whoami}, #{fragment}."},
    Proc.new { "do not think that saying '#{how_i_feel}' suffices to show the depth of how #{how_i_feel}, because more than that, #{fantasy}"},
    Proc.new { "as a #{whoami}, that #{how_i_feel} is never quite enough for you, my #{double_plus_good} #{pedestal_label}."}
  end

  def fragment
    fun = fantasy
    choose "i hope to god #{fun}", "i believe #{fun}", "i will that #{fun}"
  end

  def caused_by
    
  end
  
  def whoami
    "#{extremifier} #{humbleizer} #{groveler}"
  end

  def sign
    "your #{whoami}"
  end

  def humbleizer
    choose "undeserving","insignificant","unremarkable","fearful","menial"
  end

  def groveler
    choose "slave","servant","captive","lapdog"
  end

  def post_script
    "ps: #{i_am_stalking_you}, and hope that #{fantasy}"
  end

  def i_am_stalking_you
    "every #{time_duration} i #{stalk_action}"
  end

  def fantasy
    freq \
    Proc.new {
      make = choose "raise","nurture","bring into the world"
      babies = choose "brood of babies","#{double_plus_good} angels"
      good = double_plus_good
      effect = choose "the world becomes all the more #{good}",
                      "we may at the end of our lives rest in #{good} peace.",
                      "you, my #{pedestal_label}, would continue to live."
      "we would #{make} #{babies}, so #{effect}."
    },
    Proc.new {
      do_thing = choose "kiss","hug","read poetry to each other","massage","whisper empty nothings into each others' ears","be with each other, and oblivious to the entire world"
      affect = choose "joy", "mindfulness", "calm", "sanctity"
      "we would #{do_thing} with #{double_plus_good} #{affect}"
    }
  end

  def stalk_action
    choose "think of you","dream of us together","look at your picture and sigh"
  end

  def time_duration
    choose "once in a while","night","day","hour","minute"
  end
end

