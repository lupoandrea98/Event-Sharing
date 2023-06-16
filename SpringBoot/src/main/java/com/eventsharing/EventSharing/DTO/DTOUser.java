package com.eventsharing.EventSharing.DTO;

import com.eventsharing.EventSharing.model.Event;
import jakarta.persistence.*;

import java.util.Set;

public class DTOUser {
    private String id;
    private String username;

    private String email;

    private String image;

    private Integer favourites;

    private Integer created;

    private Integer purchased;

    private Integer invitation;
    private Boolean newInvitation;

    public DTOUser() {
    }

    public DTOUser(String id, String username, String email, String image, Integer favourites,
                   Integer created, Integer purchased, Integer invitation, Boolean newInvitation) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.image = image;
        this.favourites = favourites;
        this.created = created;
        this.purchased = purchased;
        this.invitation = invitation;
        this.newInvitation = newInvitation;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public Integer getFavourites() {
        return favourites;
    }

    public void setFavourites(Integer favourites) {
        this.favourites = favourites;
    }

    public Integer getCreated() {
        return created;
    }

    public void setCreated(Integer created) {
        this.created = created;
    }

    public Integer getPurchased() {
        return purchased;
    }

    public void setPurchased(Integer purchased) {
        this.purchased = purchased;
    }

    public Integer getInvitation() {
        return invitation;
    }

    public void setInvitation(Integer invitation) {
        this.invitation = invitation;
    }

    public Boolean getNewInvitation() {
        return newInvitation;
    }

    public void setNewInvitation(Boolean newInvitation) {
        this.newInvitation = newInvitation;
    }

    @Override
    public String toString() {
        return "DTOUser{" +
                "id='" + id + '\'' +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", favourites=" + favourites +
                ", created=" + created +
                ", purchased=" + purchased +
                ", invitation=" + invitation +
                ", newInvite=" + newInvitation +
                '}';
    }
}
