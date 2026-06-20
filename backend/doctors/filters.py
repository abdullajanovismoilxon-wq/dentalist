import django_filters

from .models import Doctor

class DoctorFilter(django_filters.FilterSet):

    city = django_filters.CharFilter(
        field_name="clinic__city",
        lookup_expr="icontains"
    )

    gender = django_filters.CharFilter(
        lookup_expr="iexact"
    )

    is_24_7 = django_filters.BooleanFilter(
        field_name="clinic__is_24_7"
    )

    specialization = django_filters.CharFilter(
        field_name="specializations__name",
        lookup_expr="icontains"
    )

    class Meta:
        model = Doctor

        fields = [
            "city",
            "gender",
            "is_24_7",
            "specialization"
        ]