package com.eventsharing.EventSharing.model;

import jakarta.persistence.*;

@Entity
@Table
public class Partecipation {
    @Id
    @GeneratedValue
    private Long id;

    @ManyToOne
    @JoinColumn(name = "userId", nullable = false)
    private User user;
    @ManyToOne
    @JoinColumn(name = "eventId", nullable = false)
    private Event event;

    public Partecipation(User user, Event event) {
        this.user = user;
        this.event = event;
    }
    public Partecipation() {}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Event getEvent() {
        return event;
    }

    public void setEvent(Event event) {
        this.event = event;
    }
}
