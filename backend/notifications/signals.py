from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model

from backend.appointments.models import Appointment
from backend.chat.models import Message
from .models import Notification

User = get_user_model()


@receiver(post_save, sender=Appointment)
def appointment_notification(sender, instance, created, **kwargs):
    if created:
        Notification.objects.create(
            recipient=instance.doctor.user,
            type="appointment_booked",
            title="New Appointment",
            message=f"{instance.patient.get_full_name()} booked an appointment on {instance.appointment_date} at {instance.appointment_time}",
            data={
                "appointment_id": instance.id,
                "doctor_id": instance.doctor.id,
                "patient_id": instance.patient.id,
            },
        )
    elif instance.status == "confirmed":
        Notification.objects.create(
            recipient=instance.patient,
            type="appointment_confirmed",
            title="Appointment Confirmed",
            message=f"Your appointment with Dr. {instance.doctor.user.get_full_name()} on {instance.appointment_date} at {instance.appointment_time} has been confirmed",
            data={"appointment_id": instance.id},
        )
    elif instance.status == "cancelled":
        if instance.patient != instance.doctor.user:
            Notification.objects.create(
                recipient=instance.doctor.user if instance.patient else instance.patient,
                type="appointment_cancelled",
                title="Appointment Cancelled",
                message=f"Appointment on {instance.appointment_date} at {instance.appointment_time} has been cancelled",
                data={"appointment_id": instance.id},
            )


@receiver(post_save, sender=Message)
def message_notification(sender, instance, created, **kwargs):
    if created:
        recipient = None
        if instance.room.patient == instance.sender:
            recipient = instance.room.doctor.user
        else:
            recipient = instance.room.patient

        Notification.objects.create(
            recipient=recipient,
            type="new_message",
            title="New Message",
            message=f"{instance.sender.get_full_name()}: {instance.text[:100]}",
            data={
                "room_id": instance.room.id,
                "sender_id": instance.sender.id,
            },
        )
