from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from backend.doctors.models import Doctor, Specialization
from backend.clinics.models import Clinic
from backend.services.models import Service

User = get_user_model()

SPECIALIZATIONS = [
    "Stomatolog", "Ortodont", "Implantolog", "Jarroh",
    "Terapevt", "Bolalar stomatologi", "Periodontolog", "Protetist",
]

DOCTORS = [
    {"first_name": "Aziz", "last_name": "Karimov", "gender": "male", "specialization": "Stomatolog", "experience": 8, "patient_type": "both", "price": 150000},
    {"first_name": "Nigora", "last_name": "Rahimova", "gender": "female", "specialization": "Ortodont", "experience": 10, "patient_type": "both", "price": 300000},
    {"first_name": "Bobur", "last_name": "Aliyev", "gender": "male", "specialization": "Implantolog", "experience": 12, "patient_type": "adults", "price": 500000},
    {"first_name": "Malika", "last_name": "Yusupova", "gender": "female", "specialization": "Bolalar stomatologi", "experience": 6, "patient_type": "children", "price": 120000},
    {"first_name": "Jasur", "last_name": "Toshmatov", "gender": "male", "specialization": "Jarroh", "experience": 15, "patient_type": "adults", "price": 800000},
    {"first_name": "Dilnoza", "last_name": "Xodjayeva", "gender": "female", "specialization": "Terapevt", "experience": 5, "patient_type": "both", "price": 100000},
    {"first_name": "Ulug'bek", "last_name": "Sultanov", "gender": "male", "specialization": "Periodontolog", "experience": 7, "patient_type": "both", "price": 200000},
    {"first_name": "Shahlo", "last_name": "Mirzayeva", "gender": "female", "specialization": "Protetist", "experience": 9, "patient_type": "both", "price": 400000},
]

SERVICES = [
    {"title": "Tish tozalash", "price": 150000, "duration_minutes": 30, "description": "Professional tish tozalash"},
    {"title": "Tish oqartirish", "price": 400000, "duration_minutes": 60, "description": "Lazer bilan tish oqartirish"},
    {"title": "Karies davolash", "price": 200000, "duration_minutes": 40, "description": "Kariesni to'ldirish"},
    {"title": "Tish implantatsiyasi", "price": 5000000, "duration_minutes": 120, "description": "Bir tish implantatsiyasi"},
    {"title": "Ortodontik davolash", "price": 3000000, "duration_minutes": 60, "description": "Bretellar bilan davolash"},
    {"title": "Tish ekstraktsiyasi", "price": 250000, "duration_minutes": 30, "description": "Murakkab tish olish"},
    {"title": "Professional gigiyena", "price": 180000, "duration_minutes": 45, "description": "Tish bo'shlig'ini tozalash"},
    {"title": "Bolalar tish davolash", "price": 100000, "duration_minutes": 30, "description": "Bolalar uchun tish davolash"},
]


class Command(BaseCommand):
    help = "Create demo data for testing"

    def handle(self, *args, **options):
        # Create specializations
        for name in SPECIALIZATIONS:
            Specialization.objects.get_or_create(name=name)
        self.stdout.write(f"Created {len(SPECIALIZATIONS)} specializations")

        # Create a clinic
        clinic, _ = Clinic.objects.get_or_create(
            name="MedDent Clinic",
            defaults={
                "address": "Toshkent shahri, Chilonzor tumani, Bunyodkor ko'chasi 12",
                "phone": "+998712345678",
                "description": "Zamonaviy stomatologiya klinikasi. Barcha turdagi tish davolash xizmatlari.",
                "is_24_7": True,
                "latitude": 41.2995,
                "longitude": 69.2401,
            },
        )

        clinic2, _ = Clinic.objects.get_or_create(
            name="DentCare Plus",
            defaults={
                "address": "Toshkent shahri, Yunusobod tumani, Amir Temur ko'chasi 45",
                "phone": "+998712345679",
                "description": "Bolalar va kattalar uchun stomatologiya xizmatlari.",
                "is_24_7": False,
                "latitude": 41.3100,
                "longitude": 69.2500,
            },
        )

        clinic3, _ = Clinic.objects.get_or_create(
            name="Shifo Stomatologiya",
            defaults={
                "address": "Toshkent shahri, Mirzo Ulug'bek tumani, Mustaqillik ko'chasi 78",
                "phone": "+998712345680",
                "image": None,
                "description": "Implantatsiya va estetik stomatologiya markazi.",
                "is_24_7": False,
                "latitude": 41.3200,
                "longitude": 69.2300,
            },
        )

        clinics = [clinic, clinic2, clinic3]

        # Create doctors
        count = 0
        for i, doc_data in enumerate(DOCTORS):
            phone = f"+9989012345{i+1:02d}"
            user, created = User.objects.get_or_create(
                phone=phone,
                defaults={
                    "username": phone,
                    "first_name": doc_data["first_name"],
                    "last_name": doc_data["last_name"],
                    "role": "doctor",
                },
            )
            if created:
                user.set_password("password123")
                user.save()

            doctor, created = Doctor.objects.get_or_create(
                user=user,
                defaults={
                    "clinic": clinics[i % len(clinics)],
                    "gender": doc_data["gender"],
                    "experience_years": doc_data["experience"],
                    "consultation_price": doc_data["price"],
                    "patient_type": doc_data["patient_type"],
                    "bio": f"{doc_data['first_name']} {doc_data['last_name']} - tajribali stomatolog.",
                    "is_active": True,
                },
            )
            if created:
                spec = Specialization.objects.get(name=doc_data["specialization"])
                doctor.specializations.add(spec)
                count += 1

                # Add a service
                svc = SERVICES[i % len(SERVICES)]
                Service.objects.get_or_create(
                    doctor=doctor,
                    title=svc["title"],
                    defaults={
                        "price": svc["price"],
                        "duration_minutes": svc["duration_minutes"],
                        "description": svc["description"],
                    },
                )

        self.stdout.write(self.style.SUCCESS(f"Created {count} doctors with services"))
