package com.eventsharing.EventSharing.model;

import jakarta.persistence.*;

@Entity
@Table
public class Favourite {
    @Id
    @GeneratedValue
    private Long id;

    @ManyToOne
    @JoinColumn(name = "userId", nullable = false)
    private User user;
    @ManyToOne
    @JoinColumn(name = "eventId", nullable = false)
    private Event event;

    public Favourite(User user, Event event) {
        this.user = user;
        this.event = event;
    }

    public Favourite() {}

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
