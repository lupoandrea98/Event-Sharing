package com.eventsharing.EventSharing.DTO;

public class DTOInvitation {

    private Long id;
    private String user1Image;
    private String user2name;
    private String eventTitle;
    private Long eventId;
    private Boolean newInvitation;
    private String state;

    public DTOInvitation(Long id, String user1Image, String user2name, String eventTitle, Long eventId, Boolean newInvitation, String state) {
        this.id = id;
        this.user1Image = user1Image;
        this.user2name = user2name;
        this.eventTitle = eventTitle;
        this.eventId = eventId;
        this.newInvitation = newInvitation;
        this.state = state;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUser1Image() {
        return user1Image;
    }

    public void setUser1Image(String user1Image) {
        this.user1Image = user1Image;
    }

    public String getUser2name() {
        return user2name;
    }

    public void setUser2name(String user2name) {
        this.user2name = user2name;
    }

    public String getEventTitle() {
        return eventTitle;
    }

    public void setEventTitle(String eventTitle) {
        this.eventTitle = eventTitle;
    }

    public Long getEventId() {
        return eventId;
    }

    public void setEventId(Long eventId) {
        this.eventId = eventId;
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
