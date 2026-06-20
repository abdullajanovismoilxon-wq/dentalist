from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status


def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is not None:
        errors = []
        for key, value in response.data.items():
            if isinstance(value, list):
                for v in value:
                    if isinstance(v, dict):
                        for sub_key, sub_value in v.items():
                            errors.append({f"{key}.{sub_key}": str(sub_value)})
                    else:
                        errors.append({key: str(v)})
            elif isinstance(value, dict):
                for sub_key, sub_value in value.items():
                    errors.append({f"{key}.{sub_key}": str(sub_value)})
            else:
                errors.append({key: str(value)})

        response.data = {"errors": errors}
    else:
        response = Response(
            {"errors": [{"detail": str(exc)}]},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )

    return response
