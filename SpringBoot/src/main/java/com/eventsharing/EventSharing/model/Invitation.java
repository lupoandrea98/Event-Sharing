package com.eventsharing.EventSharing.model;

import jakarta.persistence.*;

@Entity
@Table
public class Invitation {

    @Id
    @GeneratedValue
    private Long id;
    @ManyToOne
    @JoinColumn(name = "invitingId", nullable = false)
    private User invitingUser;
    @ManyToOne
    @JoinColumn(name = "invitedId", nullable = false)
    private User invitedUser;
    @ManyToOne
    @JoinColumn(name = "eventId", nullable = false)
    private Event event;
    private Boolean newInvitation;
    private String state; //Accepted - Refused

    public Invitation(User invitingUser, User invitedUser, Event event) {
        this.invitingUser = invitingUser;
        this.invitedUser = invitedUser;
        this.event = event;
        this.state = "Send";
        this.newInvitation = true;
    }

    public Invitation() {}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getInvitingUser() {
        return invitingUser;
    }

    public void setInvitingUser(User invitingUser) {
        this.invitingUser = invitingUser;
    }

    public User getInvitedUser() {
        return invitedUser;
    }

    public void setInvitedUser(User invitedUser) {
        this.invitedUser = invitedUser;
    }

    public Event getEvent() {
        return event;
    }

    public void setEvent(Event event) {
        this.event = event;
    }

    public Boolean getNewInvitation() {
        return newInvitation;
    }

    public void setNewInvitation(Boolean newInvitation) {
        this.newInvitation = newInvitation;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }
}
