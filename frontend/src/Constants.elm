module Constants exposing (..)

{-| Application-wide constants and static text for the frontend.
-}


-- APP BRANDING

appName : String
appName =
    "PaceMate"


appTagline : String
appTagline =
    "Mindful paced speaking practice"



-- HEADER SECTION

headerTitle : String
headerTitle =
    appName


headerSubtitle : String
headerSubtitle =
    appTagline


themeToggleTooltip : String
themeToggleTooltip =
    "Toggle theme"



-- HERO SECTION

heroTitle : String
heroTitle =
    "Practice Pacing Your Speech"


heroDescription : String
heroDescription =
    "Get real-time AI-powered feedback to help improve your speaking pace and fluency. Practice with personalized guidance."


-- Hero Features
featureRealTimeTitle : String
featureRealTimeTitle =
    "Real-time Analysis"


featureRealTimeDescription : String
featureRealTimeDescription =
    "Your speech is analyzed as you practice"


featureAiCoachTitle : String
featureAiCoachTitle =
    "AI Speech Coach"


featureAiCoachDescription : String
featureAiCoachDescription =
    "AI-powered guidance for fluency practice"


featureTrackProgressTitle : String
featureTrackProgressTitle =
    "Track Progress"


featureTrackProgressDescription : String
featureTrackProgressDescription =
    "Monitor your improvement over time"



-- BUTTONS & ACTIONS

startSessionButton : String
startSessionButton =
    "Start Session"


startSpeakingButton : String
startSpeakingButton =
    "Start Speaking"


stopSpeakingButton : String
stopSpeakingButton =
    "Stop Speaking"


practiceAgainButton : String
practiceAgainButton =
    "Practice Again"



-- BREATHING STATE

breathingInstructions : String
breathingInstructions =
    "Take a deep breath"


breathingSubtext : String
breathingSubtext =
    "Let's prepare with a calming breath"



-- PROMPT STATE

promptTitle : String
promptTitle =
    "Your Speaking Prompt"


promptDefaultText : String
promptDefaultText =
    "Tell me about your day and what you're looking forward to."


promptTipsTitle : String
promptTipsTitle =
    "Tips for this exercise:"


promptTip1 : String
promptTip1 =
    "Speak at a comfortable, unhurried pace"


promptTip2 : String
promptTip2 =
    "Take natural pauses to breathe"


promptTip3 : String
promptTip3 =
    "Focus on clarity over speed"



-- SPEAKING STATE

speakingTitle : String
speakingTitle =
    "Listening..."


speakingInstructions : String
speakingInstructions =
    "Speak naturally about the prompt above"


speakingHint : String
speakingHint =
    "The browser is capturing your speech in real-time"


speakingPlaceholder : String
speakingPlaceholder =
    "Your speech will appear here as you speak..."



-- FEEDBACK STATE

feedbackTitle : String
feedbackTitle =
    "Your Feedback"


feedbackEncouragementLabel : String
feedbackEncouragementLabel =
    "Encouragement"


feedbackPacingLabel : String
feedbackPacingLabel =
    "Pacing Analysis"


feedbackTipsLabel : String
feedbackTipsLabel =
    "Tips for Improvement"


feedbackMetricsTitle : String
feedbackMetricsTitle =
    "Speech Metrics"


feedbackMetricWords : String
feedbackMetricWords =
    "Words"


feedbackMetricSentences : String
feedbackMetricSentences =
    "Sentences"


feedbackMetricAvgLength : String
feedbackMetricAvgLength =
    "Avg. Sentence Length"


feedbackMetricWpm : String
feedbackMetricWpm =
    "Estimated WPM"



-- FOOTER

footerText : String
footerText =
    "Built with Elm + Elixir/Phoenix"


footerProjectName : String
footerProjectName =
    "PaceMate"


footerYear : String
footerYear =
    "2026"



-- ICONS (Font Awesome classes)

iconMicrophone : String
iconMicrophone =
    "fa-microphone"


iconBrain : String
iconBrain =
    "fa-brain"


iconChartLine : String
iconChartLine =
    "fa-chart-line"


iconMoon : String
iconMoon =
    "fas fa-moon"


iconSun : String
iconSun =
    "fas fa-sun"


iconHeart : String
iconHeart =
    "fas fa-heart"



-- CSS CLASSES

themeClassLight : String
themeClassLight =
    "theme-light"


themeClassDark : String
themeClassDark =
    "theme-dark"



-- ERROR MESSAGES

errorGeneric : String
errorGeneric =
    "Something went wrong. Please try again."


errorMicrophoneAccess : String
errorMicrophoneAccess =
    "Unable to access microphone. Please check your browser settings."


errorNoSpeechDetected : String
errorNoSpeechDetected =
    "No speech detected. Please try speaking again."



-- ACCESSIBILITY

ariaLabelThemeToggle : String
ariaLabelThemeToggle =
    "Toggle between light and dark theme"


ariaLabelStartSession : String
ariaLabelStartSession =
    "Start a new speaking practice session"


ariaLabelStartSpeaking : String
ariaLabelStartSpeaking =
    "Start recording your speech"


ariaLabelStopSpeaking : String
ariaLabelStopSpeaking =
    "Stop recording your speech"


ariaLabelPracticeAgain : String
ariaLabelPracticeAgain =
    "Start another practice session"



-- ANALYTICS & TRACKING

analyticsEventStartSession : String
analyticsEventStartSession =
    "session_started"


analyticsEventCompletedSession : String
analyticsEventCompletedSession =
    "session_completed"


analyticsEventFeedbackReceived : String
analyticsEventFeedbackReceived =
    "feedback_received"



-- TIMING CONSTANTS (in milliseconds)

breathingDuration : Int
breathingDuration =
    3000


pulseAnimationDuration : Int
pulseAnimationDuration =
    2000


fadeTransitionDuration : Int
fadeTransitionDuration =
    300



-- NUMERIC CONSTANTS

defaultWpmTarget : Int
defaultWpmTarget =
    150


minWordsForAnalysis : Int
minWordsForAnalysis =
    5


maxSpeechDuration : Int
maxSpeechDuration =
    300000 -- 5 minutes in milliseconds



-- URLS & LINKS

dashboardUrl : String
dashboardUrl =
    "http://localhost:4000/dashboard"


githubRepoUrl : String
githubRepoUrl =
    "https://github.com/yourusername/pacemate"


documentationUrl : String
documentationUrl =
    "./Documentation"
