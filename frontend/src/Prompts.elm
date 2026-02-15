module Prompts exposing (allPrompts, getRandomPrompt)

import Random


{-| Collection of diverse speaking prompts for practice sessions
-}
allPrompts : List String
allPrompts =
    [ -- Daily Life & Reflection (1-15)
      "Tell me about your day and what you're looking forward to."
    , "Describe your morning routine and how it sets the tone for your day."
    , "What's something that made you smile recently?"
    , "Talk about a challenge you faced this week and how you handled it."
    , "Describe your ideal weekend and what makes it special."
    , "What are three things you're grateful for today?"
    , "Share a recent conversation that had an impact on you."
    , "Describe a moment when you felt truly relaxed this week."
    , "What's a small victory you achieved recently?"
    , "Talk about a habit you're trying to build or break."
    , "Describe your favorite way to unwind after a busy day."
    , "What's something new you learned this week?"
    , "Share a funny or unexpected moment from your day."
    , "Describe how you stay organized and manage your time."
    , "What's a goal you're currently working towards?"

    -- Memories & Experiences (16-30)
    , "Describe a memorable vacation or trip you've taken."
    , "Talk about a childhood memory that still makes you laugh."
    , "Share a story about someone who inspired you."
    , "Describe a time when you stepped out of your comfort zone."
    , "What's the most interesting place you've ever visited?"
    , "Talk about a tradition your family or friends have."
    , "Describe a moment when you felt proud of yourself."
    , "Share a lesson you learned the hard way."
    , "Talk about a time when you helped someone."
    , "Describe your most memorable birthday or celebration."
    , "What's an adventure you'd like to experience someday?"
    , "Share a story about an unexpected friendship."
    , "Describe a performance, concert, or show that moved you."
    , "Talk about a time when you overcame a fear."
    , "What's a decision you made that changed your life?"

    -- Hobbies & Interests (31-45)
    , "Describe your favorite hobby and why you enjoy it."
    , "Talk about a book, movie, or show that captivated you."
    , "What's a skill you'd love to learn and why?"
    , "Describe your favorite way to be creative."
    , "Talk about a sport or physical activity you enjoy."
    , "What kind of music do you listen to and how does it affect your mood?"
    , "Describe a project you're passionate about."
    , "Talk about your favorite way to spend time outdoors."
    , "What's a game or puzzle you find engaging?"
    , "Describe how you like to learn new things."
    , "Talk about a collection or interest you have."
    , "What's your favorite type of cuisine and why?"
    , "Describe a craft or DIY project you've done."
    , "Talk about how you stay physically active."
    , "What's an interest you've had since childhood?"

    -- Food & Cooking (46-55)
    , "Describe your favorite meal and what makes it special."
    , "Talk about a memorable dining experience you've had."
    , "What's a dish you know how to cook well?"
    , "Describe your go-to comfort food."
    , "Talk about a new food you tried recently."
    , "What's your favorite restaurant and what do you order there?"
    , "Describe a family recipe or food tradition."
    , "Talk about your favorite beverage and when you enjoy it."
    , "What's a cooking disaster or funny kitchen story?"
    , "Describe your ideal breakfast, lunch, or dinner."

    -- Technology & Innovation (56-65)
    , "How has technology changed your daily life?"
    , "Describe a piece of technology you find fascinating."
    , "Talk about your favorite app or digital tool."
    , "What's your opinion on social media?"
    , "Describe how you use technology to stay connected with others."
    , "Talk about a technological advancement you're excited about."
    , "What's your approach to managing screen time?"
    , "Describe a digital skill you've developed."
    , "Talk about online communities you're part of."
    , "What's your view on the future of technology?"

    -- Nature & Environment (66-75)
    , "Describe your favorite season and why you love it."
    , "Talk about a place in nature that feels special to you."
    , "What's your favorite animal and why?"
    , "Describe a beautiful sunset or natural phenomenon you witnessed."
    , "Talk about how you connect with nature."
    , "What's your opinion on environmental conservation?"
    , "Describe your ideal garden or outdoor space."
    , "Talk about weather that affects your mood."
    , "What's a plant or tree you find interesting?"
    , "Describe an outdoor activity you enjoy."

    -- Personal Growth & Philosophy (76-90)
    , "What does success mean to you?"
    , "Describe a value or principle that guides your decisions."
    , "Talk about what happiness means to you."
    , "What's a piece of advice you'd give your younger self?"
    , "Describe how you handle stress or difficult emotions."
    , "Talk about what motivates you to keep going."
    , "What does a meaningful life look like to you?"
    , "Describe a belief you hold strongly."
    , "Talk about how you've changed over the years."
    , "What's your perspective on work-life balance?"
    , "Describe what home means to you."
    , "Talk about a quality you admire in others."
    , "What's your approach to making decisions?"
    , "Describe how you practice self-care."
    , "Talk about what you value most in relationships."

    -- Creative & Imaginative (91-105)
    , "If you could have dinner with anyone, who would it be and why?"
    , "Describe your dream home or living space."
    , "If you could travel anywhere tomorrow, where would you go?"
    , "Talk about a superpower you'd want to have."
    , "Describe what you'd do with a free day with no obligations."
    , "If you could master any skill instantly, what would it be?"
    , "Talk about a problem you'd solve if you could."
    , "Describe your ideal job or career."
    , "If you wrote a book, what would it be about?"
    , "Talk about a cause you care deeply about."
    , "Describe a perfect day from start to finish."
    , "If you could live in any time period, when would it be?"
    , "Talk about an invention you wish existed."
    , "Describe what you'd do if you won the lottery."
    , "If you could change one thing about the world, what would it be?"

    -- Social & Relationships (106-115)
    , "Describe what makes a good friend in your opinion."
    , "Talk about a quality you appreciate in your loved ones."
    , "What's your communication style with others?"
    , "Describe a time when someone showed you kindness."
    , "Talk about how you like to celebrate special occasions."
    , "What's important to you in building relationships?"
    , "Describe your favorite way to spend time with friends."
    , "Talk about a conversation topic you find fascinating."
    , "What's your approach to meeting new people?"
    , "Describe what community means to you."
    ]


{-| Generate a random index to select a prompt from the list
-}
getRandomPrompt : Random.Generator String
getRandomPrompt =
    let
        maxIndex =
            List.length allPrompts - 1
    in
    Random.int 0 maxIndex
        |> Random.map
            (\index ->
                List.drop index allPrompts
                    |> List.head
                    |> Maybe.withDefault "Tell me about your day and what you're looking forward to."
            )
