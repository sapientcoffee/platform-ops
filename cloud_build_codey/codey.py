import argparse
import sys

from google.cloud import aiplatform
from vertexai.preview.language_models import ChatModel, InputOutputTextPair
from vertexai.preview.language_models import CodeChatModel

def documentation(temperature: float = 0.5) -> object:
    parameters = {
        "temperature": temperature,  # Temperature controls the degree of randomness in token selection.
        "max_output_tokens": 1024,  # Token limit determines the maximum amount of text output.
    }

    code_chat_model = CodeChatModel.from_pretrained("codechat-bison@001")
    chat = code_chat_model.start_chat()

    response = chat.send_message(
        "Document the following code - def min(a, b): if a < b: return a else: return b", **parameters
    )
    print(f"Response from Model: {response.text}")

    # [END aiplatform_sdk_code_chat]

    return response

def releasenotes(temperature: float = 0.5) -> object:
    parameters = {
        "temperature": temperature,  # Temperature controls the degree of randomness in token selection.
        "max_output_tokens": 1024,  # Token limit determines the maximum amount of text output.
    }

    code_chat_model = CodeChatModel.from_pretrained("codechat-bison@001")
    chat = code_chat_model.start_chat()

    response = chat.send_message(
        "Please help write release notes for def min(a, b): if a < b: return a else: return b", **parameters
    )
    print(f"Response from Model: {response.text}")

    # [END aiplatform_sdk_code_chat]

    return response


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


parser = argparse.ArgumentParser()
subparsers = parser.add_subparsers()

parser_documentation = subparsers.add_parser('documentation', help='Generate docuemntation for provided code')
parser_documentation.set_defaults(func=documentation)
      
parser_release_notes = subparsers.add_parser('release-notes', help='Generate Release notes')
parser_release_notes.set_defaults(func=releasenotes)

if len(sys.argv) <= 1:
    sys.argv.append('--help')

options = parser.parse_args()
# Run the appropriate function
options.func()

# If you add command-line options, consider passing them to the function,
# e.g. `options.func(options)`