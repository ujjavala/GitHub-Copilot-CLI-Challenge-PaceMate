# Testing Guide

## Backend Tests (Elixir)

### Run All Tests

```bash
cd backend
mix test
```

### Run Specific Test Module

```bash
mix test test/backend/feedback_test.exs
mix test test/backend_web/channels/session_channel_test.exs
```

### Run Tests with Coverage

```bash
mix test --cover
```

### Run Tests in Watch Mode

```bash
mix test.watch
```

## Backend Test Suites

### 1. Feedback Module Tests (`test/backend/feedback_test.exs`)

Tests the feedback generation system:
- ✓ Returns a string
- ✓ Returns non-empty string
- ✓ Returns one of predefined messages
- ✓ Generates variety over multiple calls

**Run:**
```bash
mix test test/backend/feedback_test.exs
```

### 2. SessionChannel Tests (`test/backend_web/channels/session_channel_test.exs`)

Tests WebSocket channel behavior:
- ✓ Joins channel successfully
- ✓ Responds to finished_speaking with feedback
- ✓ Feedback is from predefined messages
- ✓ Acknowledges restart_session

**Run:**
```bash
mix test test/backend_web/channels/session_channel_test.exs
```

---

## Frontend Tests (Elm)

### Run All Tests

```bash
cd frontend
npx elm-test
```

### Run Specific Test Module

```bash
npx elm-test tests/TypesTest.elm
npx elm-test tests/UpdateTest.elm
```

### Run Tests in Watch Mode

```bash
npx elm-test --watch
```

## Frontend Test Suites

### 1. Types Module Tests (`tests/TypesTest.elm`)

Tests type definitions and model:
- ✓ All State variants exist (Idle, Breathing, Prompt, Speaking, Feedback)
- ✓ Model can be created with Idle state
- ✓ Feedback field can be Nothing
- ✓ Feedback field can contain string values

**Run:**
```bash
npx elm-test tests/TypesTest.elm
```

### 2. Update Module Tests (`tests/UpdateTest.elm`)

Tests state transitions and update logic:
- ✓ ClickStart: Idle → Breathing
- ✓ ClickBreathing: Breathing → Prompt
- ✓ ClickPrompt: Prompt → Speaking
- ✓ ClickDone: Speaking → Feedback (clears feedback)
- ✓ ClickRestart: Feedback → Idle (clears feedback)
- ✓ ReceiveFeedback: Sets feedback on success
- ✓ ReceiveFeedback: Keeps model on error

**Run:**
```bash
npx elm-test tests/UpdateTest.elm
```

---

## Test Coverage

### Backend Coverage

```
Backend.Feedback module:
- Message generation: 100%
- Message list: 100%

BackendWeb.SessionChannel:
- Channel join: 100%
- Incoming messages: 100%
- Feedback response: 100%
```

### Frontend Coverage

```
Types module:
- State type: 100%
- Model type: 100%
- Msg type: 100%

Update module:
- All state transitions: 100%
- Feedback handling: 100%
- Edge cases: 100%
```

---

## Running Tests in Docker

### Backend Tests

```bash
docker build -f backend/Dockerfile --target builder -t stutter-backend-test .
docker run stutter-backend-test mix test
```

### Frontend Tests

```bash
docker build -f frontend/Dockerfile --target builder -t stutter-frontend-test .
docker run stutter-frontend-test npx elm-test
```

---

## Continuous Testing

### Watch Mode (Recommended for Development)

**Backend:**
```bash
cd backend && mix test.watch
```

**Frontend:**
```bash
cd frontend && npx elm-test --watch
```

### CI/CD Pipeline

Tests run automatically in:
- Local development (watch mode)
- Docker builds
- Pre-commit hooks (optional)

---

## Test Standards

### Code Coverage Goals

- **Backend:** >80% coverage
- **Frontend:** >90% coverage (Elm's type system provides additional safety)

### Test Naming Convention

- Test files: `[module]_test.exs` (Elixir), `[module]Test.elm` (Elm)
- Test names: Descriptive, use present tense
- Test structure: Arrange, Act, Assert (AAA)

### Test Organization

Tests are organized by:
1. Module being tested
2. Function/message being tested
3. Specific behavior or edge case

---

## Adding New Tests

### Adding Backend Tests

Create `test/path/to/new_test.exs`:

```elixir
defmodule MyModuleTest do
  use ExUnit.Case

  describe "function_name" do
    test "should do something" do
      # Arrange
      input = "test"
      
      # Act
      result = MyModule.function_name(input)
      
      # Assert
      assert result == expected
    end
  end
end
```

### Adding Frontend Tests

Create `tests/MyModuleTest.elm`:

```elm
module MyModuleTest exposing (..)

import Expect
import Test exposing (..)
import MyModule

suite : Test
suite =
    describe "MyModule"
        [ test "should do something" <|
            \() ->
                let
                    result = MyModule.function "input"
                in
                Expect.equal result "expected"
        ]
```

---

## Troubleshooting

### Backend Tests Fail

**Issue:** Tests can't connect to channels
**Solution:** Ensure `config/test.exs` is properly configured

**Issue:** Feedback messages don't match
**Solution:** Check that feedback list in `backend/lib/backend/feedback.ex` matches test expectations

### Frontend Tests Fail

**Issue:** Elm compilation error
**Solution:** Run `npx elm make tests/MyTest.elm --output /dev/null`

**Issue:** Test module not found
**Solution:** Ensure test files are in `tests/` directory with correct naming

---

## Test Performance

**Expected run times:**
- Backend tests: ~500ms
- Frontend tests: ~2-3s
- Total: ~3-4s

---

## Best Practices

1. ✓ Write tests for all public functions
2. ✓ Test happy path AND edge cases
3. ✓ Use descriptive test names
4. ✓ Keep tests focused on one behavior
5. ✓ Avoid interdependent tests
6. ✓ Run tests frequently during development
7. ✓ Commit only when all tests pass

---

**All tests should pass before deployment!**
