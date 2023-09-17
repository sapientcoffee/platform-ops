from google.cloud import aiplatform

# import vertexai
# from vertexai.language_models import CodeChatModel

# vertexai.init(project="codey-coffee", location="us-central1")
# chat_model = CodeChatModel.from_pretrained("codechat-bison@001")
# parameters = {
#     "candidate_count": 1,
#     "max_output_tokens": 1024,
#     "temperature": 0.2
# }


from vertexai.preview.language_models import ChatModel, InputOutputTextPair
from vertexai.preview.language_models import CodeChatModel

def science_tutoring(temperature: float = 0.2) -> None:
    chat_model = ChatModel.from_pretrained("chat-bison@001")

    # TODO developer - override these parameters as needed:
    parameters = {
        "temperature": temperature,  # Temperature controls the degree of randomness in token selection.
        "max_output_tokens": 256,  # Token limit determines the maximum amount of text output.
        "top_p": 0.95,  # Tokens are selected from most probable to least until the sum of their probabilities equals the top_p value.
        "top_k": 40,  # A top_k of 1 means the selected token is the most probable among all tokens.
    }

    chat = chat_model.start_chat(
        context="My name is Miles. You are an astronomer, knowledgeable about the solar system.",
        examples=[
            InputOutputTextPair(
                input_text="How many moons does Mars have?",
                output_text="The planet Mars has two moons, Phobos and Deimos.",
            ),
        ],
    )

    response = chat.send_message(
        "How many planets are there in the solar system?", **parameters
    )
    print(f"Response from Model: {response.text}")



def write_a_function(temperature: float = 0.5) -> object:
    """Example of using Code Chat Model to write a function."""

    # TODO developer - override these parameters as needed:
    parameters = {
        "temperature": temperature,  # Temperature controls the degree of randomness in token selection.
        "max_output_tokens": 1024,  # Token limit determines the maximum amount of text output.
    }

    code_chat_model = CodeChatModel.from_pretrained("codechat-bison@001")
    chat = code_chat_model.start_chat()

    response = chat.send_message(
        "Please help write a function to calculate the min of two numbers", **parameters
    )
    print(f"Response from Model: {response.text}")
    # [END aiplatform_sdk_code_chat]

    return response

def release_notes(temperature: float = 0.5) -> object:

    # TODO developer - override these parameters as needed:
    parameters = {
        "temperature": temperature,  # Temperature controls the degree of randomness in token selection.
        "max_output_tokens": 1024,  # Token limit determines the maximum amount of text output.
    }

    code_chat_model = CodeChatModel.from_pretrained("codechat-bison@001")
    chat = code_chat_model.start_chat()

    response = chat.send_message(
        "Please help writerelease notes for def min(a, b): if a < b: return a else: return b", **parameters
    )
    print(f"Response from Model: {response.text}")
    # [END aiplatform_sdk_code_chat]

    return response


if __name__ == "__main__":
    # science_tutoring()
    # write_a_function()
    release_notes()

